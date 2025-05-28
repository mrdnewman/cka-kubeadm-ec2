#!/bin/bash
# -----------------------------------------------------------------------------
# Script: rollback_vpc.sh
#
# Purpose:
#   Fully deletes an AWS VPC and its dependent resources to perform a clean
#   rollback of infrastructure created in error or during testing.
#
# What it does:
#   🚨 Given a VPC ID, this script:
#     - Deletes all associated NAT Gateways (and waits for cleanup)
#     - Detaches and deletes Internet Gateways
#     - Disassociates and deletes non-main route tables
#     - Deletes all security groups except the default
#     - Detaches (if needed) and deletes all ENIs (network interfaces)
#     - Deletes all subnets in the VPC
#     - Deletes the VPC itself
#
# Usage:
#   ./rollback_vpc.sh <vpc-id>
#
# Requirements:
#   - AWS CLI must be installed and configured
#   - Proper IAM permissions to delete VPC and related resources
#
# Example:
#   ./rollback_vpc.sh vpc-0abc123def456ghij
#
# Notes:
#   ❗ This script is destructive. Use only on test/dev VPCs unless you’re 
#      trying to make cloud infrastructure disappear like a magician.
# -----------------------------------------------------------------------------

#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <vpc-id>"
  exit 1
fi

VPC_ID="$1"

echo "🚨 Starting VPC rollback for VPC: $VPC_ID"

# Delete NAT Gateways
echo "🌐 Deleting NAT Gateways..."
NAT_GATEWAYS=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$VPC_ID" --query 'NatGateways[].NatGatewayId' --output text)
if [ -n "$NAT_GATEWAYS" ]; then
  for natgw in $NAT_GATEWAYS; do
    aws ec2 delete-nat-gateway --nat-gateway-id "$natgw"
  done
  echo "⏳ Waiting for NAT Gateways to be deleted..."
  for natgw in $NAT_GATEWAYS; do
    aws ec2 wait nat-gateway-deleted --nat-gateway-ids "$natgw"
  done
else
  echo "✅ No NAT Gateways found."
fi

# Detach and delete Internet Gateways
echo "🚪 Detaching and deleting Internet Gateways..."
IGWS=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query 'InternetGateways[].InternetGatewayId' --output text)
for igw in $IGWS; do
  aws ec2 detach-internet-gateway --internet-gateway-id "$igw" --vpc-id "$VPC_ID"
  aws ec2 delete-internet-gateway --internet-gateway-id "$igw"
done

# Disassociate and delete custom route tables
echo "🛣️ Disassociating and deleting custom route tables..."
ROUTE_TABLES=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --query 'RouteTables[?Associations[?Main==`false`]].RouteTableId' --output text)
for rtb in $ROUTE_TABLES; do
  ASSOCIATIONS=$(aws ec2 describe-route-tables --route-table-ids "$rtb" --query 'RouteTables[0].Associations[?RouteTableAssociationId!=null].RouteTableAssociationId' --output text)
  for assoc in $ASSOCIATIONS; do
    aws ec2 disassociate-route-table --association-id "$assoc"
  done
  aws ec2 delete-route-table --route-table-id "$rtb"
done

# Delete security groups (except default)
echo "🔐 Deleting security groups (except default)..."
SGS=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --query 'SecurityGroups[?GroupName!=`default`].GroupId' --output text)
for sg in $SGS; do
  aws ec2 delete-security-group --group-id "$sg"
done

# Delete network interfaces
echo "📡 Deleting network interfaces in the VPC..."
ENIS=$(aws ec2 describe-network-interfaces --filters "Name=vpc-id,Values=$VPC_ID" --query 'NetworkInterfaces[].NetworkInterfaceId' --output text)
for eni in $ENIS; do
  ATTACHMENT_ID=$(aws ec2 describe-network-interfaces --network-interface-ids "$eni" --query 'NetworkInterfaces[0].Attachment.AttachmentId' --output text)
  if [ "$ATTACHMENT_ID" != "None" ]; then
    aws ec2 detach-network-interface --attachment-id "$ATTACHMENT_ID" --force
    sleep 2
  fi
  aws ec2 delete-network-interface --network-interface-id "$eni"
done

# Delete subnets
echo "🧱 Deleting subnets..."
SUBNETS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[].SubnetId' --output text)
for subnet in $SUBNETS; do
  aws ec2 delete-subnet --subnet-id "$subnet"
done

# Finally delete the VPC
echo "💣 Deleting VPC $VPC_ID"
aws ec2 delete-vpc --vpc-id "$VPC_ID"

echo "✅ VPC rollback complete."

