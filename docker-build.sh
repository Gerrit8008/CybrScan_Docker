#!/bin/bash

# CybrScan Docker Build Script

echo "🚀 Building CybrScan Docker images..."

# Build production image
echo "Building production image..."
docker build -t cybrscan:latest .

# Build development image
echo "Building development image..."
docker build -f Dockerfile.dev -t cybrscan:dev .

echo "✅ Build complete!"
echo ""
echo "To run in development mode:"
echo "  docker-compose -f docker-compose.yml -f docker-compose.dev.yml up"
echo ""
echo "To run in production mode:"
echo "  docker-compose up -d"