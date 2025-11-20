#!/bin/bash
set -e

# ----------------------------------------
# Configuration
# ----------------------------------------
CHECKOV_SARIF="checkov.sarif"
TARGET_DIR="${1:-.}"

# ----------------------------------------
# Function: Run Checkov Scan
# ----------------------------------------
echo "----------------------------------------"
echo "▶️ Running Checkov Scan"
echo "----------------------------------------"

# Run Checkov, output to console and SARIF file
checkov -d "$TARGET_DIR" -o sarif --config-file .checkov.yml

# Ensure SARIF file exists even if scan fails or is skipped
if [ ! -f "$CHECKOV_SARIF" ]; then
    echo '{"runs":[]}' > "$CHECKOV_SARIF"
fi

echo "✅ Checkov SARIF output: $CHECKOV_SARIF"
