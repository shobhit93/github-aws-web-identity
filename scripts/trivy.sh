#!/bin/bash
set -euo pipefail

# Real repo root
REPO_ROOT="$(git rev-parse --show-toplevel)"

echo "📁 Running Trivy IaC scan in repo: $REPO_ROOT"

# Ensure trivy exists
if ! command -v trivy >/dev/null 2>&1; then
    echo "❌ Trivy is not installed!"
    exit 1
fi

cd "$REPO_ROOT"

echo "🔎 Running: trivy config --severity CRITICAL,HIGH --exit-code 1 --format sarif ."

trivy config --exit-code 1 --severity CRITICAL,HIGH --format sarif . \
  2> >(tee /dev/stderr) \
  > trivy-iac.sarif

echo "✅ Trivy IaC scan completed!"
