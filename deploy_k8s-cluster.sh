
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

MASTER_KEY_PATH="$HOME/.ssh/cka-key.pub"
TEMPLATE_PATH="./templates/bootstrap-worker.sh.tpl"
OUTPUT_PATH="./scripts/bootstrap-worker.sh"

echo "📦 Terraform init..."
terraform init -input=false >/dev/null

echo "🔑 Step 0: Creating key pair..."
terraform apply -target=module.key_pair -auto-approve

echo "🚀 Step 1: Creating master node..."
terraform apply -target=module.master -auto-approve

echo "📡 Step 2: Fetching master public IP..."
MASTER_IP=$(terraform output -raw master_public_ip)

echo "🔐 Step 3: Grabbing join command from master node..."
./scripts/get_join_command.sh "$MASTER_IP" "$MASTER_KEY_PATH"

echo "📄 Step 4: Injecting join command into worker bootstrap..."
JOIN_COMMAND=$(cat ./scripts/joincommand.sh | tr -d '\r')
cat > "$OUTPUT_PATH" <<EOF
#!/bin/bash
set -e
${JOIN_COMMAND}
EOF

chmod +x "$OUTPUT_PATH"

echo "🛠️ Step 5: Deploying worker nodes..."
terraform apply -target=module.worker -auto-approve

echo "✅ Cluster is live!"

