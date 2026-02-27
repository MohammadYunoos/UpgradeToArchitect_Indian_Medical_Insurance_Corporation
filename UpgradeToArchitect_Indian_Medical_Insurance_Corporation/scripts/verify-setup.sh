#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Medical Insurance - Local Setup Checklist${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check files exist
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $2"
        return 0
    else
        echo -e "${RED}✗${NC} $2 (NOT FOUND)"
        return 1
    fi
}

check_executable() {
    if [ -x "$1" ]; then
        echo -e "${GREEN}✓${NC} $2 (executable)"
        return 0
    else
        echo -e "${RED}✗${NC} $2 (NOT executable)"
        return 1
    fi
}

echo -e "${YELLOW}Documentation Files:${NC}"
check_file "RUN_LOCALLY.md" "RUN_LOCALLY.md"
check_file "LOCAL_DEVELOPMENT.md" "LOCAL_DEVELOPMENT.md"
check_file "LOCAL_SETUP_SUMMARY.md" "LOCAL_SETUP_SUMMARY.md"
check_file "SETUP_COMPLETE.md" "SETUP_COMPLETE.md"

echo ""
echo -e "${YELLOW}Configuration Files:${NC}"
check_file "infra/docker-compose.yml" "infra/docker-compose.yml (updated)"
check_file "infra/init-db.sql" "infra/init-db.sql (new)"
check_file "Makefile" "Makefile (new)"

echo ""
echo -e "${YELLOW}Scripts:${NC}"
check_executable "scripts/local-dev-setup.sh" "scripts/local-dev-setup.sh"

echo ""
echo -e "${YELLOW}Requirements Files:${NC}"
check_file "internet-site/requirements.txt" "internet-site/requirements.txt (updated)"
check_file "intranet-site/requirements.txt" "intranet-site/requirements.txt (updated)"

echo ""
echo -e "${YELLOW}Environment Examples:${NC}"
check_file "internet-site/.env.example" "internet-site/.env.example (updated)"
check_file "intranet-site/.env.example" "intranet-site/.env.example (updated)"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo -e "${BLUE}Quick Start Options:${NC}"
echo ""
echo -e "${YELLOW}1. Automated Setup (Recommended):${NC}"
echo "   ./scripts/local-dev-setup.sh"
echo ""
echo -e "${YELLOW}2. Manual Docker Compose:${NC}"
echo "   cd infra && docker-compose up -d"
echo ""
echo -e "${YELLOW}3. Using Make Commands:${NC}"
echo "   make help              # See all commands"
echo "   make setup             # Automated setup"
echo "   make up                # Start services"
echo ""

echo -e "${BLUE}Service URLs (after starting):${NC}"
echo "   Intranet:  http://localhost:8001/docs"
echo "   Internet:  http://localhost:8002/docs"
echo "   PgAdmin:   http://localhost:5050"
echo "   Database:  localhost:5432"
echo ""

echo -e "${BLUE}Documentation:${NC}"
echo "   Start with: RUN_LOCALLY.md"
echo "   Quick ref:  LOCAL_SETUP_SUMMARY.md"
echo "   Full guide: LOCAL_DEVELOPMENT.md"
echo ""

echo -e "${GREEN}Ready to go! 🚀${NC}"
