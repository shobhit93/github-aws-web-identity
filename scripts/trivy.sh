#!/bin/bash
set -euo pipefail

# ----------------------------------------
# Helper: check if Trivy is installed
# ----------------------------------------
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

if ! command_exists trivy; then
  echo "❌ Trivy is not installed. Install it via install_tools.sh first."
  exit 1
fi

echo "🧹 Clearing Trivy corrupted cache (known GH Actions issue)..."
rm -rf ~/.cache/trivy
mkdir -p ~/.cache/trivy

echo "🔄 Updating Trivy DB..."
trivy --download-db-only || true
echo "🔄 Updating Trivy Cloud Policies..."
trivy --reset-policy || true

echo "----------------------------------------"
echo "▶️ Running Trivy IaC Scan"
echo "----------------------------------------"

# You can pass target dir as $1, or default to current dir
TARGET_DIR="${1:-.}"

trivy config \
  --exit-code 1 \
  --severity CRITICAL,HIGH \
  --format sarif \
  --output trivy-iac.sarif \
  "$TARGET_DIR" \

echo "✅ Trivy IaC SARIF written to trivy-iac.sarif"
