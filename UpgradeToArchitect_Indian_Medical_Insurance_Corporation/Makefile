.PHONY: help setup up down logs logs-intranet logs-internet logs-db restart clean test install-deps

help:
	@echo "Medical Insurance App - Local Development Commands"
	@echo ""
	@echo "Setup & Start:"
	@echo "  make setup              - Automated setup (recommended)"
	@echo "  make up                 - Start with PostgreSQL (persistent)"
	@echo "  make up-memory          - Start with in-memory SQLite (fast)"
	@echo "  make down               - Stop all services"
	@echo "  make down-clean         - Stop and remove all data"
	@echo ""
	@echo "Logs & Monitoring:"
	@echo "  make logs               - View all service logs"
	@echo "  make logs-intranet      - View intranet site logs"
	@echo "  make logs-internet      - View internet site logs"
	@echo "  make logs-db            - View database logs"
	@echo "  make status             - Check service status"
	@echo ""
	@echo "Restart & Rebuild:"
	@echo "  make restart            - Restart all services"
	@echo "  make restart-intranet   - Restart intranet site"
	@echo "  make restart-internet   - Restart internet site"
	@echo "  make build              - Rebuild all Docker images"
	@echo ""
	@echo "Database:"
	@echo "  make db-shell           - Open PostgreSQL shell"
	@echo "  make db-reset           - Reset database to initial state"
	@echo ""
	@echo "Testing & Development:"
	@echo "  make test               - Run all tests"
	@echo "  make test-intranet      - Run intranet tests"
	@echo "  make test-internet      - Run internet tests"
	@echo "  make lint               - Run code linting"
	@echo "  make format             - Format code with black"
	@echo ""
	@echo "Development Server (Python):"
	@echo "  make venv               - Create virtual environments"
	@echo "  make install-deps       - Install Python dependencies"
	@echo "  make dev-intranet       - Run intranet in dev mode (requires Python)"
	@echo "  make dev-internet       - Run internet in dev mode (requires Python)"
	@echo ""
	@echo "Services & URLs:"
	@echo "  Intranet API:    http://localhost:8001"
	@echo "  Internet API:    http://localhost:8002"
	@echo "  Intranet Docs:   http://localhost:8001/docs"
	@echo "  Internet Docs:   http://localhost:8002/docs"
	@echo "  PgAdmin:         http://localhost:5050 (PostgreSQL mode only)"
	@echo "  PostgreSQL:      localhost:5432"
	@echo ""
	@echo "Database Options:"
	@echo "  PostgreSQL:      Persistent, full-featured (make up)"
	@echo "  In-Memory SQLite: Fast, no persistence (make up-memory)"

# Setup & Start Commands
setup:
	@echo "Running automated setup..."
	@chmod +x scripts/local-dev-setup.sh
	@./scripts/local-dev-setup.sh

up:
	@echo "Starting all services with PostgreSQL (persistent)..."
	@cd infra && docker-compose up -d
	@echo "Waiting for services to start..."
	@sleep 10
	@echo "✓ Services started!"
	@echo ""
	@echo "Services available at:"
	@echo "  Intranet: http://localhost:8001/docs"
	@echo "  Internet: http://localhost:8002/docs"
	@echo "  PgAdmin:  http://localhost:5050"

up-memory:
	@echo "Starting all services with in-memory SQLite (fast)..."
	@cd infra && docker-compose -f docker-compose.inmemory.yml up -d
	@echo "Waiting for services to start..."
	@sleep 5
	@echo "✓ Services started!"
	@echo ""
	@echo "Services available at:"
	@echo "  Intranet: http://localhost:8001/docs"
	@echo "  Internet: http://localhost:8002/docs"
	@echo ""
	@echo "📌 Note: Using in-memory SQLite (data NOT persisted)"

down:
	@echo "Stopping all services..."
	@cd infra && docker-compose down
	@echo "✓ Services stopped"

down-memory:
	@echo "Stopping in-memory services..."
	@cd infra && docker-compose -f docker-compose.inmemory.yml down
	@echo "✓ Services stopped"

down-clean:
	@echo "Stopping all services and removing data..."
	@cd infra && docker-compose down -v
	@echo "✓ All services stopped and data removed"

# Logs Commands
logs:
	@cd infra && docker-compose logs -f

logs-memory:
	@cd infra && docker-compose -f docker-compose.inmemory.yml logs -f

logs-intranet:
	@cd infra && docker-compose logs -f intranet-site

logs-internet:
	@cd infra && docker-compose logs -f internet-site

logs-db:
	@cd infra && docker-compose logs -f postgres

status:
	@cd infra && docker-compose ps

# Restart & Rebuild Commands
restart:
	@echo "Restarting all services..."
	@cd infra && docker-compose restart
	@echo "✓ Services restarted"

restart-intranet:
	@echo "Restarting intranet site..."
	@cd infra && docker-compose restart intranet-site
	@echo "✓ Intranet restarted"

restart-internet:
	@echo "Restarting internet site..."
	@cd infra && docker-compose restart internet-site
	@echo "✓ Internet restarted"

build:
	@echo "Building Docker images..."
	@cd infra && docker-compose build --no-cache
	@echo "✓ Images built"

# Database Commands
db-shell:
	@echo "Opening PostgreSQL shell..."
	@cd infra && docker-compose exec postgres psql -U medical_user -d medical_insurance

db-reset:
	@echo "Resetting database..."
	@cd infra && docker-compose down -v
	@cd infra && docker-compose up -d postgres
	@sleep 5
	@cd infra && docker-compose exec -T postgres psql -U medical_user -d medical_insurance < init-db.sql
	@echo "✓ Database reset"

# Testing Commands
test:
	@echo "Running all tests..."
	@cd infra && docker-compose exec intranet-site python -m pytest tests/ -v
	@cd infra && docker-compose exec internet-site python -m pytest tests/ -v

test-intranet:
	@echo "Running intranet tests..."
	@cd infra && docker-compose exec intranet-site python -m pytest tests/ -v

test-internet:
	@echo "Running internet tests..."
	@cd infra && docker-compose exec internet-site python -m pytest tests/ -v

lint:
	@echo "Running linting..."
	@cd intranet-site && python -m flake8 app/ tests/
	@cd internet-site && python -m flake8 app/ tests/

format:
	@echo "Formatting code..."
	@cd intranet-site && python -m black app/ tests/
	@cd internet-site && python -m black app/ tests/

# Development Server Commands (Python)
venv:
	@echo "Creating virtual environments..."
	@cd intranet-site && python3 -m venv venv
	@cd internet-site && python3 -m venv venv
	@echo "✓ Virtual environments created"
	@echo ""
	@echo "Activate with:"
	@echo "  source intranet-site/venv/bin/activate"
	@echo "  source internet-site/venv/bin/activate"

install-deps:
	@echo "Installing Python dependencies..."
	@cd intranet-site/venv && source bin/activate && pip install -r ../requirements.txt
	@cd internet-site/venv && source bin/activate && pip install -r ../requirements.txt
	@echo "✓ Dependencies installed"

dev-intranet: venv install-deps
	@echo "Starting intranet in dev mode..."
	@cd intranet-site && source venv/bin/activate && python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8001

dev-internet: venv install-deps
	@echo "Starting internet in dev mode..."
	@cd internet-site && source venv/bin/activate && python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8002
