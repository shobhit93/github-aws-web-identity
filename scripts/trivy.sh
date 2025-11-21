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
TRIVY_CACHE_DIR="${TRIVY_CACHE_DIR:-$HOME/.cache/trivy}"
TRIVY_POLICY_PATH="${TRIVY_POLICY_PATH:-$TRIVY_CACHE_DIR/policy}"

echo "🧹 Clearing Trivy cache..."
rm -rf "$TRIVY_CACHE_DIR"
mkdir -p "$TRIVY_POLICY_PATH/policy/content/policies/cloud/policies/aws"

export TRIVY_CACHE_DIR
export TRIVY_POLICY_PATH


echo "----------------------------------------"
echo "▶️ Running Trivy IaC Scan"
echo "----------------------------------------"

# ----------------------------------------
# Determine target directory
# ----------------------------------------
TARGET_DIR="$(git rev-parse --show-toplevel)"
echo "Target dir: $TARGET_DIR"
echo "📁 Scanning target: $TARGET_DIR"

# Optional: show Terraform / YAML / IaC files found
echo "🔍 IaC files found in repo"

trivy config \
  --exit-code 1 \
  --severity CRITICAL,HIGH \
  --format sarif \
  --output trivy-iac.sarif \
  "$TARGET_DIR" \

echo "✅ Trivy IaC SARIF written to trivy-iac.sarif"
