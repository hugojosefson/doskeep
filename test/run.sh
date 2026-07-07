#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."
IMAGE="docker.io/hugojosefson/steamdeck-dos-test"

echo ">>> Building test image..."
docker build -t "$IMAGE" -f test/Dockerfile .

echo ""
echo ">>> Running tests..."
docker run --rm "$IMAGE"
