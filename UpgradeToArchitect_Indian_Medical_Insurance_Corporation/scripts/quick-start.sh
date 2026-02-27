#!/bin/bash

###############################################################################
# Quick Start - Native Python Apps (No Docker)
# 
# This script starts both apps using native Python in separate processes
# Requires Python 3.9+
#
# Usage: ./scripts/quick-start.sh
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

print_header() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  Medical Insurance App - Quick Start   ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

print_step() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}$1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

cleanup() {
    echo ""
    echo -e "${YELLOW}Shutting down services...${NC}"
    if [ -n "$INTRANET_PID" ]; then
        kill $INTRANET_PID 2>/dev/null || true
    fi
    if [ -n "$INTERNET_PID" ]; then
        kill $INTERNET_PID 2>/dev/null || true
    fi
    print_success "Services stopped"
    exit 0
}

trap cleanup SIGINT SIGTERM

# === START ===

print_header

# Step 1: Check Python
print_step "Step 1: Checking Python"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗ Python 3 not found${NC}"
    exit 1
fi
print_success "Python $(python3 --version | awk '{print $2}')"

# Step 2: Check ports
print_step "Step 2: Checking ports"
for port in 8001 8002; do
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${RED}✗ Port $port already in use${NC}"
        exit 1
    fi
done
print_success "Ports 8001 and 8002 are available"

# Step 3: Install dependencies
print_step "Step 3: Installing dependencies"

print_info "Installing intranet-site dependencies..."
pip3 install -q -r intranet-site/requirements.txt
print_success "intranet-site ready"

print_info "Installing internet-site dependencies..."
pip3 install -q -r internet-site/requirements.txt
print_success "internet-site ready"

# Step 4: Start applications
print_step "Step 4: Starting applications"

print_info "Starting Intranet Site (port 8001)..."
cd "$PROJECT_ROOT/intranet-site"
python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload > /tmp/intranet.log 2>&1 &
INTRANET_PID=$!
print_success "Intranet Site started (PID: $INTRANET_PID)"

print_info "Starting Internet Site (port 8002)..."
cd "$PROJECT_ROOT/internet-site"
python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8002 --reload > /tmp/internet.log 2>&1 &
INTERNET_PID=$!
print_success "Internet Site started (PID: $INTERNET_PID)"

# Step 5: Display summary
print_step "Services Running"

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ All services are ready!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""

echo -e "${CYAN}📱 Access URLs:${NC}"
echo -e "  ${YELLOW}Intranet API:${NC}   http://localhost:8001"
echo -e "  ${YELLOW}Internet API:${NC}   http://localhost:8002"
echo -e "  ${YELLOW}Intranet Docs:${NC}  http://localhost:8001/docs"
echo -e "  ${YELLOW}Internet Docs:${NC}  http://localhost:8002/docs"
echo ""

echo -e "${CYAN}📊 Database:${NC}"
echo -e "  ${YELLOW}Type:${NC}  SQLite In-Memory (ultra-fast)"
echo ""

echo -e "${CYAN}📋 Logs:${NC}"
echo -e "  ${YELLOW}Intranet:${NC}  tail -f /tmp/intranet.log"
echo -e "  ${YELLOW}Internet:${NC}  tail -f /tmp/internet.log"
echo ""

echo -e "${CYAN}🛑 To stop all services:${NC}"
echo -e "  Press ${YELLOW}Ctrl+C${NC} in this terminal"
echo ""

# Wait indefinitely
wait
