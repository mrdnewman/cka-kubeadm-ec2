
#!/bin/bash
set -euo pipefail

MASTER_IP=$1
SSH_KEY_PATH=$2

# Step 1: Run kubeadm token create on master to generate the join command
#ssh -o StrictHostKeyChecking=no -i "$SSH_KEY_PATH" ec2-user@"$MASTER_IP" "sudo kubeadm token create --print-join-command > /joincommand.sh && sudo chmod +x /joincommand.sh"

# Runs the kubeadm command remotely and streams its output back to your local machine
# Saves it into your local ./scripts/joincommand.sh file
# Sets execute permissions on it (optional, but consistent)
ssh -o StrictHostKeyChecking=no -i "$SSH_KEY_PATH" ec2-user@"$MASTER_IP" "sudo kubeadm token create --print-join-command" > ./scripts/joincommand.sh
chmod +x ./scripts/joincommand.sh


# Step 2: Copy the joincommand.sh file to local machine
scp -o StrictHostKeyChecking=no -i "$SSH_KEY_PATH" ec2-user@"$MASTER_IP":/joincommand.sh ./scripts/joincommand.sh

#!/bin/bash
set -euo pipefail

MASTER_IP=$1
SSH_KEY_PATH=$2

echo "🔐 Grabbing kubeadm join command from $MASTER_IP..."

# Run kubeadm on master and stream output back to local machine
ssh -o StrictHostKeyChecking=no -i "$SSH_KEY_PATH" ec2-user@"$MASTER_IP" \
  "sudo kubeadm token create --print-join-command" \
  > ./scripts/joincommand.sh

chmod +x ./scripts/joincommand.sh

echo "✅ Join command saved to ./scripts/joincommand.sh"

