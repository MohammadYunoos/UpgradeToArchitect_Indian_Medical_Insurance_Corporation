#!/bin/bash

# Medical Insurance Platform - Quick Start Script
# Usage: ./scripts/setup.sh [intranet|internet|both]

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Medical Insurance Platform - Setup${NC}"
echo "=================================="

# Check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}Error: Python 3 is not installed${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Python 3 found${NC}"
    
    # Check Docker (optional but recommended)
    if ! command -v docker &> /dev/null; then
        echo -e "${YELLOW}⚠ Docker is not installed (optional)${NC}"
    else
        echo -e "${GREEN}✓ Docker found${NC}"
    fi
    
    echo ""
}

# Setup Python environment for a specific site
setup_venv() {
    local site=$1
    local site_dir="$PROJECT_ROOT/$site"
    
    echo -e "${YELLOW}Setting up $site...${NC}"
    
    # Create virtual environment
    python3 -m venv "$site_dir/venv"
    echo -e "${GREEN}✓ Virtual environment created${NC}"
    
    # Activate and install dependencies
    source "$site_dir/venv/bin/activate"
    pip install --upgrade pip setuptools wheel > /dev/null
    pip install -r "$site_dir/requirements.txt" > /dev/null
    echo -e "${GREEN}✓ Dependencies installed${NC}"
    
    # Create .env file
    if [ ! -f "$site_dir/.env" ]; then
        cp "$site_dir/.env.example" "$site_dir/.env"
        echo -e "${GREEN}✓ Environment file created${NC}"
    fi
    
    deactivate
    echo ""
}

# Setup both sites
setup_both() {
    setup_venv "intranet-site"
    setup_venv "internet-site"
}

# Test the setup
test_setup() {
    local site=$1
    local site_dir="$PROJECT_ROOT/$site"
    
    echo -e "${YELLOW}Testing $site...${NC}"
    
    source "$site_dir/venv/bin/activate"
    
    # Run basic import test
    python3 -c "from app.main import app; print('✓ App imports successfully')"
    
    deactivate
    echo ""
}

# Main execution
check_prerequisites

SITE="${1:-both}"

case $SITE in
    intranet)
        setup_venv "intranet-site"
        test_setup "intranet-site"
        ;;
    internet)
        setup_venv "internet-site"
        test_setup "internet-site"
        ;;
    both)
        setup_venv "intranet-site"
        setup_venv "internet-site"
        test_setup "intranet-site"
        test_setup "internet-site"
        ;;
    *)
        echo -e "${RED}Invalid argument: $SITE${NC}"
        echo "Usage: ./scripts/setup.sh [intranet|internet|both]"
        exit 1
        ;;
esac

echo -e "${GREEN}Setup completed successfully!${NC}"
echo ""
echo "Next steps:"
echo "1. For intranet-site:"
echo "   cd intranet-site"
echo "   source venv/bin/activate"
echo "   python -m uvicorn app.main:app --reload"
echo ""
echo "2. For internet-site:"
echo "   cd internet-site"
echo "   source venv/bin/activate"
echo "   python -m uvicorn app.main:app --reload"
echo ""
echo "3. Or use Docker Compose:"
echo "   docker-compose -f infra/docker-compose.yml up"
