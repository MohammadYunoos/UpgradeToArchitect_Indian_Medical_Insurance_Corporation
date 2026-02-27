#!/bin/bash

# Medical Insurance Platform - Initialization Script
# This script verifies the project structure and provides quick start options

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║   Medical Insurance Platform - Azure App Service Deployment   ║"
echo "║                      Lab Environment                          ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check project structure
check_structure() {
    echo -e "${YELLOW}Checking project structure...${NC}"
    
    local files=(
        "README.md"
        "QUICK_START.md"
        "PROJECT_SUMMARY.md"
        "DEPLOYMENT_SUMMARY.md"
        "intranet-site/app/main.py"
        "intranet-site/Dockerfile"
        "intranet-site/requirements.txt"
        "intranet-site/tests/test_main.py"
        "intranet-site/.github/workflows/deploy-intranet.yml"
        "internet-site/app/main.py"
        "internet-site/Dockerfile"
        "internet-site/requirements.txt"
        "internet-site/tests/test_main.py"
        "internet-site/.github/workflows/deploy-internet.yml"
        "infra/azure-deployment.md"
        "infra/docker-compose.yml"
        "docs/INTRANET_API.md"
        "docs/INTERNET_API.md"
        ".gitignore"
    )
    
    local found=0
    local missing=0
    
    for file in "${files[@]}"; do
        if [ -f "$SCRIPT_DIR/$file" ]; then
            echo -e "${GREEN}✓${NC} $file"
            ((found++))
        else
            echo -e "${RED}✗${NC} $file"
            ((missing++))
        fi
    done
    
    echo ""
    echo -e "Status: ${GREEN}$found files found${NC}, ${RED}$missing files missing${NC}"
    echo ""
}

# Show quick start guide
show_quick_start() {
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}QUICK START OPTIONS${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo "1. ${YELLOW}Fast Deployment (5 minutes)${NC}"
    echo "   → Read: QUICK_START.md"
    echo "   → Contains: Pre-configured Azure CLI commands"
    echo ""
    
    echo "2. ${YELLOW}Detailed Setup (Step-by-Step)${NC}"
    echo "   → Read: infra/azure-deployment.md"
    echo "   → Contains: Comprehensive Azure setup guide"
    echo ""
    
    echo "3. ${YELLOW}Local Testing (Docker Compose)${NC}"
    echo "   Command: docker-compose -f infra/docker-compose.yml up"
    echo "   Tests:   curl http://localhost:8001/health"
    echo ""
    
    echo "4. ${YELLOW}Local Python Development${NC}"
    echo "   Command: ./scripts/setup.sh both"
    echo "   Then:    cd intranet-site && source venv/bin/activate && python -m uvicorn app.main:app --reload"
    echo ""
}

# Show file information
show_file_info() {
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}KEY FILES${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${YELLOW}📄 Documentation${NC}"
    echo "  • README.md                 - Project overview"
    echo "  • QUICK_START.md            - 5-minute deployment guide"
    echo "  • PROJECT_SUMMARY.md        - Comprehensive overview"
    echo "  • DEPLOYMENT_SUMMARY.md     - Quick reference"
    echo "  • infra/azure-deployment.md - Complete Azure guide"
    echo ""
    
    echo -e "${YELLOW}🐍 Applications${NC}"
    echo "  • intranet-site/            - Employee portal (Port 8001)"
    echo "  • internet-site/            - Customer portal (Port 8002)"
    echo ""
    
    echo -e "${YELLOW}🔧 Configuration${NC}"
    echo "  • intranet-site/Dockerfile  - Container config"
    echo "  • internet-site/Dockerfile  - Container config"
    echo "  • infra/docker-compose.yml  - Local Docker setup"
    echo "  • scripts/setup.sh           - Quick setup script"
    echo ""
    
    echo -e "${YELLOW}📚 API Documentation${NC}"
    echo "  • docs/INTRANET_API.md      - API reference"
    echo "  • docs/INTERNET_API.md      - API reference"
    echo ""
    
    echo -e "${YELLOW}🚀 CI/CD${NC}"
    echo "  • intranet-site/.github/workflows/deploy-intranet.yml"
    echo "  • internet-site/.github/workflows/deploy-internet.yml"
    echo ""
}

# Show prerequisites
show_prerequisites() {
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}PREREQUISITES${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo "Required:"
    if command -v az &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Azure CLI"
    else
        echo -e "  ${RED}✗${NC} Azure CLI (Install: brew install azure-cli)"
    fi
    
    echo "Optional:"
    if command -v docker &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Docker"
    else
        echo -e "  ${YELLOW}○${NC} Docker (Install from: docker.com)"
    fi
    
    if command -v python3 &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Python 3"
    else
        echo -e "  ${YELLOW}○${NC} Python 3 (Install: brew install python3)"
    fi
    
    echo ""
}

# Show next steps
show_next_steps() {
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}NEXT STEPS${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo "1. ${BLUE}Read the documentation:${NC}"
    echo "   • Start with: QUICK_START.md"
    echo "   • For details: infra/azure-deployment.md"
    echo ""
    
    echo "2. ${BLUE}Choose your deployment method:${NC}"
    echo "   • Fast: QUICK_START.md (5 minutes)"
    echo "   • Detailed: infra/azure-deployment.md (step-by-step)"
    echo "   • Local: docker-compose -f infra/docker-compose.yml up"
    echo ""
    
    echo "3. ${BLUE}After deployment:${NC}"
    echo "   • Health Check: curl https://medical-intranet-site.azurewebsites.net/health"
    echo "   • API Docs: https://medical-intranet-site.azurewebsites.net/docs"
    echo "   • API Docs: https://medical-internet-site.azurewebsites.net/docs"
    echo ""
    
    echo "4. ${BLUE}Test the APIs:${NC}"
    echo "   • Use the interactive Swagger UI at /docs"
    echo "   • Or use cURL (see API documentation)"
    echo ""
}

# Show statistics
show_statistics() {
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}PROJECT STATISTICS${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    local py_files=$(find "$SCRIPT_DIR" -name "*.py" -type f | wc -l)
    local doc_files=$(find "$SCRIPT_DIR" -name "*.md" -type f | wc -l)
    local yml_files=$(find "$SCRIPT_DIR" -name "*.yml" -o -name "*.yaml" | wc -l)
    local docker_files=$(find "$SCRIPT_DIR" -name "Dockerfile" -type f | wc -l)
    
    echo "Code Files:"
    echo "  • Python Files:  $py_files"
    echo "  • Docker Files:  $docker_files"
    echo ""
    
    echo "Configuration:"
    echo "  • Workflow Files: $yml_files"
    echo ""
    
    echo "Documentation:"
    echo "  • Markdown Files: $doc_files"
    echo ""
}

# Show summary
show_summary() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              ✓ Project is Ready for Deployment!              ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Main execution
main() {
    check_structure
    show_file_info
    show_prerequisites
    show_quick_start
    show_next_steps
    show_statistics
    show_summary
    
    echo ""
    echo -e "${YELLOW}📖 READ FIRST: QUICK_START.md${NC}"
    echo "   → 5-minute deployment guide with all commands"
    echo ""
    echo -e "${YELLOW}🔗 PROJECT LINKS:${NC}"
    echo "   • Code: medical-insurance-app/"
    echo "   • Docs: See README.md and documentation files"
    echo ""
    echo -e "${GREEN}Happy Deploying! 🚀${NC}"
    echo ""
}

main
