# Remove EC2 manually and it seems to work




#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <vpc-id>"
  exit 1
fi

VPC_ID="$1"

echo "🚨 Starting VPC rollback for VPC: $VPC_ID"

# step 0: Disassociate all EIPs attached to the VPC's network interfaces

# List all Elastic IPs with their association IDs that are attached to ENIs in the VPC
aws ec2 describe-addresses --query "Addresses[?NetworkInterfaceId!=null].{AllocationId:AllocationId, AssociationId:AssociationId, NetworkInterfaceId:NetworkInterfaceId}" --output json | jq -c '.[]' | while read addr; do
  ALLOC_ID=$(echo $addr | jq -r '.AllocationId')
  ASSOC_ID=$(echo $addr | jq -r '.AssociationId')
  ENI_ID=$(echo $addr | jq -r '.NetworkInterfaceId')

  # Check if ENI is in the VPC you want to clean up
  VPC_ID_OF_ENI=$(aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID --query 'NetworkInterfaces[0].VpcId' --output text)
  
  if [ "$VPC_ID_OF_ENI" = "vpc-0eee1bf487cf5912f" ]; then
    echo "Disassociating EIP $ALLOC_ID from ENI $ENI_ID"
    aws ec2 disassociate-address --association-id $ASSOC_ID
  fi
done

# Step 1: Delete NAT Gateways
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

# Step 2: Disassociate all Elastic IPs attached to ENIs in this VPC
echo "🔌 Disassociating all Elastic IPs attached to ENIs in VPC $VPC_ID..."

while true; do
  # Find all EIPs attached to network interfaces in this VPC
  ADDRESSES=$(aws ec2 describe-addresses --query 'Addresses[?NetworkInterfaceId!=null].[AllocationId,AssociationId,NetworkInterfaceId]' --output json)

  COUNT=$(echo "$ADDRESSES" | jq '[.[] | select(.[2] != null)] | length')

  if [ "$COUNT" -eq 0 ]; then
    echo "✅ All Elastic IPs disassociated."
    break
  fi

  echo "⏳ Found $COUNT Elastic IP(s) still associated, disassociating..."

  echo "$ADDRESSES" | jq -c '.[]' | while read -r addr; do
    ALLOC_ID=$(echo "$addr" | jq -r '.[0]')
    ASSOC_ID=$(echo "$addr" | jq -r '.[1]')
    ENI_ID=$(echo "$addr" | jq -r '.[2]')

    # Confirm ENI belongs to the VPC before disassociating
    ENI_VPC=$(aws ec2 describe-network-interfaces --network-interface-ids "$ENI_ID" --query 'NetworkInterfaces[0].VpcId' --output text)
    if [ "$ENI_VPC" == "$VPC_ID" ]; then
      echo "➡️ Disassociating EIP AllocationId $ALLOC_ID (AssociationId $ASSOC_ID) from ENI $ENI_ID"
      aws ec2 disassociate-address --association-id "$ASSOC_ID"
    fi
  done

  echo "⏳ Sleeping 15 seconds before re-checking EIPs..."
  sleep 15
done

# Step 3: Detach and delete Internet Gateways
echo "🚪 Detaching and deleting Internet Gateways..."
IGWS=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query 'InternetGateways[].InternetGatewayId' --output text)
for igw in $IGWS; do
  echo "➡️ Detaching Internet Gateway $igw from VPC $VPC_ID"
  aws ec2 detach-internet-gateway --internet-gateway-id "$igw" --vpc-id "$VPC_ID"
  echo "➡️ Deleting Internet Gateway $igw"
  aws ec2 delete-internet-gateway --internet-gateway-id "$igw"
done

# Step 4: Disassociate and delete custom route tables
echo "🛣️ Disassociating and deleting custom route tables..."
ROUTE_TABLES=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --query 'RouteTables[?Associations[?Main==`false`]].RouteTableId' --output text)
for rtb in $ROUTE_TABLES; do
  ASSOCIATIONS=$(aws ec2 describe-route-tables --route-table-ids "$rtb" --query 'RouteTables[0].Associations[?RouteTableAssociationId!=null].RouteTableAssociationId' --output text)
  for assoc in $ASSOCIATIONS; do
    aws ec2 disassociate-route-table --association-id "$assoc"
  done
  aws ec2 delete-route-table --route-table-id "$rtb"
done

# Step 5: Delete security groups except default
echo "🔐 Deleting security groups (except default)..."
SGS=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --query 'SecurityGroups[?GroupName!=`default`].GroupId' --output text)
for sg in $SGS; do
  aws ec2 delete-security-group --group-id "$sg"
done

# Step 6: Delete network interfaces
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

# Step 7: Delete subnets
echo "🧱 Deleting subnets..."
SUBNETS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[].SubnetId' --output text)
for subnet in $SUBNETS; do
  aws ec2 delete-subnet --subnet-id "$subnet"
done

# Step 8: Finally delete the VPC
echo "💣 Deleting VPC $VPC_ID"
aws ec2 delete-vpc --vpc-id "$VPC_ID"

echo "✅ VPC rollback complete."

