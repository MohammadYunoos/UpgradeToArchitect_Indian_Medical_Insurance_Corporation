#!/bin/bash

###############################################################################
# Medical Insurance App - Local Startup Script
# 
# This script starts both the Internet and Intranet sites locally
# 
# Usage: ./scripts/start-local.sh [option]
#   docker      - Start with Docker Compose (PostgreSQL) - DEFAULT
#   memory      - Start with Docker Compose (in-memory SQLite)
#   native      - Start with native Python (no containers)
#   help        - Show this help message
#
# Example:
#   ./scripts/start-local.sh              # Uses Docker (default)
#   ./scripts/start-local.sh native       # Uses native Python
#   ./scripts/start-local.sh memory       # Uses in-memory SQLite
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default option
START_MODE="${1:-docker}"

# Get the project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

###############################################################################
# Helper Functions
###############################################################################

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

show_help() {
    cat << EOF

${BLUE}Medical Insurance App - Local Startup Script${NC}

${YELLOW}Usage:${NC}
    ./scripts/start-local.sh [option]

${YELLOW}Options:${NC}
    docker      Start with Docker Compose (PostgreSQL) - RECOMMENDED
    memory      Start with Docker Compose (in-memory SQLite) - FAST
    native      Start with native Python (no containers)
    help        Show this help message

${YELLOW}Examples:${NC}
    ./scripts/start-local.sh              # Default: Docker with PostgreSQL
    ./scripts/start-local.sh docker       # Explicit: Docker with PostgreSQL
    ./scripts/start-local.sh memory       # Fast: Docker with in-memory SQLite
    ./scripts/start-local.sh native       # Native: Python without containers

${YELLOW}What Gets Started:${NC}
    docker mode:
        • PostgreSQL Database (localhost:5432)
        • PgAdmin Web UI (http://localhost:5050)
        • Intranet Site (http://localhost:8001)
        • Internet Site (http://localhost:8002)

    memory mode:
        • Intranet Site with SQLite (http://localhost:8001)
        • Internet Site with SQLite (http://localhost:8002)
        • Fast startup, no persistence

    native mode:
        • Intranet Site (http://localhost:8001)
        • Internet Site (http://localhost:8002)
        • Python virtual environments

${YELLOW}Default Credentials:${NC}
    PostgreSQL:
        User: medical_user
        Password: medical_password
        Database: medical_insurance
    
    PgAdmin:
        Email: admin@medical.local
        Password: admin

${YELLOW}Access URLs:${NC}
    Intranet API: http://localhost:8001
    Internet API: http://localhost:8002
    API Docs: http://localhost:8001/docs (intranet), http://localhost:8002/docs (internet)
    PgAdmin: http://localhost:5050 (docker/memory modes only)

${YELLOW}Stopping Services:${NC}
    Press Ctrl+C in any terminal to stop services

EOF
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        echo "Install from: https://www.docker.com/products/docker-desktop"
        exit 1
    fi
    print_success "Docker found: $(docker --version)"
}

check_docker_running() {
    if ! docker info &> /dev/null; then
        print_error "Docker is not running"
        echo "Start Docker Desktop and try again"
        exit 1
    fi
    print_success "Docker is running"
}

check_python() {
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed or not in PATH"
        exit 1
    fi
    print_success "Python found: $(python3 --version)"
}

check_ports() {
    local ports=("8001" "8002" "5432" "5050")
    local mode=$1
    
    # In native mode, we don't need PostgreSQL port
    if [ "$mode" == "native" ]; then
        ports=("8001" "8002")
    fi
    
    for port in "${ports[@]}"; do
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            print_warning "Port $port is already in use"
            return 1
        fi
    done
    
    print_success "Required ports are available"
    return 0
}

wait_for_service() {
    local url=$1
    local timeout=$2
    local elapsed=0
    
    while [ $elapsed -lt $timeout ]; do
        if curl -s "$url" > /dev/null 2>&1; then
            return 0
        fi
        sleep 1
        elapsed=$((elapsed + 1))
    done
    
    return 1
}

###############################################################################
# Start with Docker Compose (PostgreSQL)
###############################################################################

start_docker_postgres() {
    print_header "Starting with Docker Compose (PostgreSQL)"
    
    # Check prerequisites
    print_info "Checking prerequisites..."
    check_docker
    check_docker_running
    check_ports "docker"
    
    # Start services
    print_info "Starting Docker Compose services..."
    cd "$PROJECT_ROOT/infra"
    
    if docker-compose up -d; then
        print_success "Docker Compose started successfully"
    else
        print_error "Failed to start Docker Compose"
        exit 1
    fi
    
    # Wait for services
    print_info "Waiting for services to be ready..."
    
    # Wait for PostgreSQL
    print_info "Waiting for PostgreSQL (max 30 seconds)..."
    if docker-compose exec -T postgres pg_isready -U medical_user -d medical_insurance >/dev/null 2>&1; then
        print_success "PostgreSQL is ready"
    else
        sleep 5
        if docker-compose exec -T postgres pg_isready -U medical_user -d medical_insurance >/dev/null 2>&1; then
            print_success "PostgreSQL is ready"
        else
            print_warning "PostgreSQL might still be starting..."
        fi
    fi
    
    # Wait for services to be healthy
    sleep 5
    
    # Show status
    print_info "Checking service status..."
    docker-compose ps
    
    # Display access information
    print_success "Services started successfully!"
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ✓ All services are running!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}Access URLs:${NC}"
    echo -e "  ${YELLOW}Intranet API:${NC}    http://localhost:8001"
    echo -e "  ${YELLOW}Internet API:${NC}    http://localhost:8002"
    echo -e "  ${YELLOW}Intranet Docs:${NC}   http://localhost:8001/docs"
    echo -e "  ${YELLOW}Internet Docs:${NC}   http://localhost:8002/docs"
    echo -e "  ${YELLOW}PgAdmin UI:${NC}      http://localhost:5050"
    echo -e "  ${YELLOW}PostgreSQL:${NC}      localhost:5432"
    echo ""
    echo -e "${CYAN}Database Credentials:${NC}"
    echo -e "  ${YELLOW}User:${NC}     medical_user"
    echo -e "  ${YELLOW}Password:${NC} medical_password"
    echo -e "  ${YELLOW}Database:${NC} medical_insurance"
    echo ""
    echo -e "${CYAN}PgAdmin Credentials:${NC}"
    echo -e "  ${YELLOW}Email:${NC}    admin@medical.local"
    echo -e "  ${YELLOW}Password:${NC} admin"
    echo ""
    echo -e "${CYAN}View logs:${NC}"
    echo -e "  docker-compose logs -f"
    echo -e "  docker-compose logs -f intranet-site"
    echo -e "  docker-compose logs -f internet-site"
    echo -e "  docker-compose logs -f postgres"
    echo ""
    echo -e "${CYAN}Stop services:${NC}"
    echo -e "  docker-compose down"
    echo ""
    
    # Keep the script running to show logs
    print_info "Showing logs (Ctrl+C to stop)..."
    cd "$PROJECT_ROOT/infra"
    docker-compose logs -f
}

###############################################################################
# Start with Docker Compose (In-Memory SQLite)
###############################################################################

start_docker_memory() {
    print_header "Starting with Docker Compose (In-Memory SQLite)"
    
    # Check prerequisites
    print_info "Checking prerequisites..."
    check_docker
    check_docker_running
    check_ports "memory"
    
    # Start services
    print_info "Starting Docker Compose services..."
    cd "$PROJECT_ROOT/infra"
    
    if docker-compose -f docker-compose.inmemory.yml up -d; then
        print_success "Docker Compose started successfully"
    else
        print_error "Failed to start Docker Compose"
        exit 1
    fi
    
    sleep 3
    
    # Show status
    print_info "Checking service status..."
    docker-compose -f docker-compose.inmemory.yml ps
    
    # Display access information
    print_success "Services started successfully!"
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ✓ All services are running (SQLite In-Memory)${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}Access URLs:${NC}"
    echo -e "  ${YELLOW}Intranet API:${NC}    http://localhost:8001"
    echo -e "  ${YELLOW}Internet API:${NC}    http://localhost:8002"
    echo -e "  ${YELLOW}Intranet Docs:${NC}   http://localhost:8001/docs"
    echo -e "  ${YELLOW}Internet Docs:${NC}   http://localhost:8002/docs"
    echo ""
    echo -e "${CYAN}Database:${NC}"
    echo -e "  ${YELLOW}Type:${NC}       SQLite (In-Memory)"
    echo -e "  ${YELLOW}Persistence:${NC} No - Data resets on restart"
    echo -e "  ${YELLOW}Speed:${NC}       Ultra-fast startup"
    echo ""
    echo -e "${CYAN}View logs:${NC}"
    echo -e "  docker-compose -f infra/docker-compose.inmemory.yml logs -f"
    echo ""
    echo -e "${CYAN}Stop services:${NC}"
    echo -e "  docker-compose -f infra/docker-compose.inmemory.yml down"
    echo ""
    
    # Keep the script running to show logs
    print_info "Showing logs (Ctrl+C to stop)..."
    cd "$PROJECT_ROOT/infra"
    docker-compose -f docker-compose.inmemory.yml logs -f
}

###############################################################################
# Start with Native Python
###############################################################################

setup_venv() {
    local site=$1
    local venv_path="$PROJECT_ROOT/$site/venv"
    
    if [ ! -d "$venv_path" ]; then
        print_info "Creating virtual environment for $site..."
        python3 -m venv "$venv_path"
        print_success "Virtual environment created"
    fi
    
    # Activate and install dependencies
    print_info "Installing dependencies for $site..."
    source "$venv_path/bin/activate"
    pip install -q --upgrade pip setuptools wheel
    pip install -q -r "$PROJECT_ROOT/$site/requirements.txt"
    print_success "Dependencies installed for $site"
}

start_native_python() {
    print_header "Starting with Native Python (No Containers)"
    
    # Check prerequisites
    print_info "Checking prerequisites..."
    check_python
    check_ports "native"
    
    # Setup virtual environments
    print_info "Setting up Python environments..."
    setup_venv "intranet-site"
    setup_venv "internet-site"
    
    print_success "Python environments ready"
    echo ""
    
    # Display information about starting in separate terminals
    echo -e "${GREEN}════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ✓ Python environments are ready!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Now start each app in separate terminals:${NC}"
    echo ""
    echo -e "${CYAN}Terminal 1 (Intranet Site):${NC}"
    echo -e "  cd $PROJECT_ROOT/intranet-site"
    echo -e "  source venv/bin/activate"
    echo -e "  uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload"
    echo ""
    echo -e "${CYAN}Terminal 2 (Internet Site):${NC}"
    echo -e "  cd $PROJECT_ROOT/internet-site"
    echo -e "  source venv/bin/activate"
    echo -e "  uvicorn app.main:app --host 0.0.0.0 --port 8002 --reload"
    echo ""
    echo -e "${CYAN}Access URLs:${NC}"
    echo -e "  ${YELLOW}Intranet API:${NC}    http://localhost:8001"
    echo -e "  ${YELLOW}Internet API:${NC}    http://localhost:8002"
    echo -e "  ${YELLOW}Intranet Docs:${NC}   http://localhost:8001/docs"
    echo -e "  ${YELLOW}Internet Docs:${NC}   http://localhost:8002/docs"
    echo ""
    
    # Start intranet site
    print_info "Starting Intranet Site (port 8001)..."
    source "$PROJECT_ROOT/intranet-site/venv/bin/activate"
    cd "$PROJECT_ROOT/intranet-site"
    uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload &
    INTRANET_PID=$!
    
    sleep 2
    
    # Start internet site
    print_info "Starting Internet Site (port 8002)..."
    source "$PROJECT_ROOT/internet-site/venv/bin/activate"
    cd "$PROJECT_ROOT/internet-site"
    uvicorn app.main:app --host 0.0.0.0 --port 8002 --reload &
    INTERNET_PID=$!
    
    sleep 2
    
    echo ""
    print_success "Both sites started successfully!"
    echo ""
    echo -e "${CYAN}Process IDs:${NC}"
    echo -e "  ${YELLOW}Intranet:${NC} $INTRANET_PID"
    echo -e "  ${YELLOW}Internet:${NC} $INTERNET_PID"
    echo ""
    echo -e "${CYAN}To stop all services:${NC}"
    echo -e "  kill $INTRANET_PID $INTERNET_PID"
    echo ""
    
    # Wait for processes
    wait $INTRANET_PID $INTERNET_PID
}

###############################################################################
# Main Script Logic
###############################################################################

main() {
    case "$START_MODE" in
        docker)
            start_docker_postgres
            ;;
        memory)
            start_docker_memory
            ;;
        native)
            start_native_python
            ;;
        help|--help|-h)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $START_MODE"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main
