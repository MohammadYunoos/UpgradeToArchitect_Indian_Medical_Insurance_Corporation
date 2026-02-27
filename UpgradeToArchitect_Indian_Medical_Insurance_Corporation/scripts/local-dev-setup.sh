#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Medical Insurance - Local Dev Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command_exists docker; then
    echo -e "${RED}✗ Docker is not installed${NC}"
    echo "  Install from: https://www.docker.com/products/docker-desktop"
    exit 1
else
    DOCKER_VERSION=$(docker --version)
    echo -e "${GREEN}✓ Docker installed: $DOCKER_VERSION${NC}"
fi

if ! command_exists docker-compose; then
    echo -e "${RED}✗ Docker Compose is not installed${NC}"
    echo "  Install from: https://docs.docker.com/compose/install/"
    exit 1
else
    COMPOSE_VERSION=$(docker-compose --version)
    echo -e "${GREEN}✓ Docker Compose installed: $COMPOSE_VERSION${NC}"
fi

echo ""
echo -e "${YELLOW}Starting services...${NC}"
echo ""

# Navigate to infra directory
cd "$(dirname "$0")/infra" || exit 1

# Start services
echo -e "${BLUE}Running: docker-compose up -d${NC}"
docker-compose up -d

# Wait for services to be ready
echo ""
echo -e "${YELLOW}Waiting for services to be ready...${NC}"
sleep 10

# Check if services are running
echo ""
echo -e "${BLUE}Checking service status...${NC}"
docker-compose ps

# Display service URLs and credentials
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ All services are running!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Access the services:${NC}"
echo ""
echo -e "  ${YELLOW}Internet Site API${NC}"
echo -e "    URL: ${GREEN}http://localhost:8002${NC}"
echo -e "    Docs: ${GREEN}http://localhost:8002/docs${NC}"
echo ""
echo -e "  ${YELLOW}Intranet Site API${NC}"
echo -e "    URL: ${GREEN}http://localhost:8001${NC}"
echo -e "    Docs: ${GREEN}http://localhost:8001/docs${NC}"
echo ""
echo -e "  ${YELLOW}PostgreSQL Database${NC}"
echo -e "    Host: ${GREEN}localhost${NC}"
echo -e "    Port: ${GREEN}5432${NC}"
echo -e "    User: ${GREEN}medical_user${NC}"
echo -e "    Password: ${GREEN}medical_password${NC}"
echo -e "    Database: ${GREEN}medical_insurance${NC}"
echo ""
echo -e "  ${YELLOW}PgAdmin Web UI${NC}"
echo -e "    URL: ${GREEN}http://localhost:5050${NC}"
echo -e "    Email: ${GREEN}admin@medical.local${NC}"
echo -e "    Password: ${GREEN}admin${NC}"
echo ""
echo -e "${BLUE}Useful commands:${NC}"
echo ""
echo -e "  ${YELLOW}View logs:${NC}"
echo "    docker-compose logs -f                    # All services"
echo "    docker-compose logs -f intranet-site      # Intranet only"
echo "    docker-compose logs -f internet-site      # Internet only"
echo "    docker-compose logs -f postgres           # Database only"
echo ""
echo -e "  ${YELLOW}Stop services:${NC}"
echo "    docker-compose down                       # Stop all"
echo "    docker-compose down -v                    # Stop and remove data"
echo ""
echo -e "  ${YELLOW}Restart services:${NC}"
echo "    docker-compose restart                    # All services"
echo "    docker-compose restart intranet-site      # Specific service"
echo ""
echo -e "  ${YELLOW}Access database:${NC}"
echo "    docker-compose exec postgres psql -U medical_user -d medical_insurance"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Open http://localhost:8001/docs to test the Intranet API"
echo "  2. Open http://localhost:8002/docs to test the Internet API"
echo "  3. Visit http://localhost:5050 to manage the database"
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"
