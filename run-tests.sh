#!/bin/bash
set -euo pipefail

IMAGE="docker.io/hugojosefson/steamdeck-dos-test"

echo ">>> Building test image..."
docker build -t "$IMAGE" -f Dockerfile.test .

echo ""
echo ">>> Running tests..."
docker run --rm "$IMAGE"
