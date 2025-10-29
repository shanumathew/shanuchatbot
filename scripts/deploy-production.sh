#!/bin/bash
# Production Deployment Script - Local/VPS/Cloud
# Deploy React Chatbot using Docker Compose

set -e

echo "=========================================="
echo "React Chatbot - Production Deployment"
echo "=========================================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose is not installed${NC}"
    exit 1
fi

echo -e "${BLUE}Step 1: Building Docker image...${NC}"
docker-compose -f docker-compose.prod.yml build

echo -e "${BLUE}Step 2: Starting services...${NC}"
docker-compose -f docker-compose.prod.yml up -d

echo -e "${BLUE}Step 3: Verifying deployment...${NC}"
sleep 5

# Check if services are running
if docker-compose -f docker-compose.prod.yml ps | grep -q "Up"; then
    echo -e "${GREEN}✓ Services are running${NC}"
else
    echo -e "${RED}✗ Services failed to start${NC}"
    docker-compose -f docker-compose.prod.yml logs
    exit 1
fi

echo ""
echo -e "${GREEN}=========================================="
echo "Deployment Successful!"
echo "==========================================${NC}"
echo ""

echo -e "${BLUE}Access your app:${NC}"
echo "  http://localhost"
echo "  https://localhost (if SSL configured)"
echo ""

echo -e "${BLUE}Useful commands:${NC}"
echo "  View logs: docker-compose -f docker-compose.prod.yml logs -f"
echo "  Stop: docker-compose -f docker-compose.prod.yml down"
echo "  Restart: docker-compose -f docker-compose.prod.yml restart"
echo "  Status: docker-compose -f docker-compose.prod.yml ps"
echo ""
