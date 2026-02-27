# Local Development Setup Guide

This guide walks you through setting up both the Internet and Intranet sites locally.

## 🚀 Quick Start (30 seconds)

### Option 1: Fastest - Using Scripts (Recommended):
```bash
./scripts/quick-start.sh
```
✅ Intranet: http://localhost:8001 | Internet: http://localhost:8002 | Auto-reloading

### Option 2: Using Make Commands:
```bash
make dev-intranet    # Terminal 1
make dev-internet    # Terminal 2
```
✅ Intranet: http://localhost:8001 | Internet: http://localhost:8002

### Option 3: Manual (Native Python):
```bash
# Terminal 1
cd intranet-site && pip install -r requirements.txt && uvicorn app.main:app --port 8001 --reload

# Terminal 2
cd internet-site && pip install -r requirements.txt && uvicorn app.main:app --port 8002 --reload
```
✅ Intranet: http://localhost:8001 | Internet: http://localhost:8002

---

## Prerequisites

- Docker Desktop (includes Docker and Docker Compose)
- Python 3.9+ (for direct Python development)
- Git

### Install Prerequisites

**macOS:**
```bash
# Install Docker Desktop from: https://www.docker.com/products/docker-desktop
# Or use Homebrew:
brew install docker docker-compose

# Verify installations
docker --version
docker-compose --version
python3 --version
```

## Quick Start with Docker Compose (Optional)

### 1. Start All Services with Docker

If you prefer containerized deployment:

```bash
cd infra
docker-compose up -d
```

This will start:
- **PostgreSQL Database** at `localhost:5432`
- **PgAdmin** (Database UI) at `http://localhost:5050`
- **Intranet Site** at `http://localhost:8001`
- **Internet Site** at `http://localhost:8002`

### 2. Verify Services are Running

```bash
# Check status of all containers
docker-compose ps

# View logs from all services
docker-compose logs -f

# View logs from specific service
docker-compose logs -f intranet-site
docker-compose logs -f internet-site
docker-compose logs -f postgres
```

### 3. Access the Services

| Service | URL | Default Credentials |
|---------|-----|-------------------|
| Internet Site API | http://localhost:8002 | N/A |
| Intranet Site API | http://localhost:8001 | N/A |
| PgAdmin Web UI | http://localhost:5050 | Email: `admin@medical.local` / Password: `admin` |
| PostgreSQL | `localhost:5432` | User: `medical_user` / Password: `medical_password` |

### 4. Stop All Services

```bash
cd infra
docker-compose down

# Also remove volumes (database data) if you want a fresh start
docker-compose down -v
```

---

---

## Local Development Without Docker (Native Python - RECOMMENDED)

This is the recommended approach for local development. No containers needed!

### Option A: Quick Start (SQLite In-Memory - No Database Setup)

**Easiest option - no database installation needed!**

**Terminal 1 - Start Intranet Site:**
```bash
cd intranet-site
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload
```

**Terminal 2 - Start Internet Site:**
```bash
cd internet-site
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8002 --reload
```

Both sites will be available at:
- Intranet API: http://localhost:8001 (Docs: http://localhost:8001/docs)
- Internet API: http://localhost:8002 (Docs: http://localhost:8002/docs)

### Option B: Using Scripts (SIMPLEST)

```bash
# Ultra-simple one-command startup
./scripts/quick-start.sh
```

This handles all setup automatically and starts both sites.

### Option C: Using Make Commands

From the project root, use the Makefile shortcuts:

**Terminal 1:**
```bash
make dev-intranet
```

**Terminal 2:**
```bash
make dev-internet
```

---

## Local Development With PostgreSQL Database

If you need a persistent database instead of in-memory SQLite:

### Option 1: Start PostgreSQL Container + Native Python Apps

**Terminal 1 - Start just the PostgreSQL container:**
```bash
docker-compose -f infra/docker-compose.yml up postgres pgadmin
```

This gives you:
- PostgreSQL at `localhost:5432`
- PgAdmin UI at `http://localhost:5050`

**Terminal 2 - Set Environment Variables and Start Intranet Site:**
```bash
cat > intranet-site/.env << 'EOF'
APP_NAME=intranet-site
ENVIRONMENT=development
LOG_LEVEL=INFO
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8001,http://localhost:8002
DATABASE_URL=postgresql://medical_user:medical_password@localhost:5432/medical_insurance
DB_HOST=localhost
DB_PORT=5432
DB_NAME=medical_insurance
DB_USER=medical_user
DB_PASSWORD=medical_password
EOF

cd intranet-site
pip install -r requirements.txt
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

**Terminal 3 - Set Environment Variables and Start Internet Site:**
```bash
cat > internet-site/.env << 'EOF'
APP_NAME=internet-site
ENVIRONMENT=development
LOG_LEVEL=INFO
ALLOWED_ORIGINS=*
DATABASE_URL=postgresql://medical_user:medical_password@localhost:5432/medical_insurance
DB_HOST=localhost
DB_PORT=5432
DB_NAME=medical_insurance
DB_USER=medical_user
DB_PASSWORD=medical_password
EOF

cd internet-site
pip install -r requirements.txt
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8002
```

### Option 2: With Local PostgreSQL Installation

If you want PostgreSQL installed locally on your machine:

**macOS with Homebrew:**
```bash
# Install PostgreSQL
brew install postgresql

# Start PostgreSQL service
brew services start postgresql

# Create database and user
createdb medical_insurance
createuser medical_user
psql medical_insurance < infra/init-db.sql
```

Then follow the same steps as Option 1 (Terminals 2-3 above).

---

## Database Management

### Database Options

| Option | Setup | Speed | Data Persistence | Best For |
|--------|-------|-------|------------------|----------|
| **In-Memory SQLite** | 0 min (automatic) | ⚡ Ultra-fast | ❌ No (resets on restart) | Testing, TDD, CI/CD |
| **PostgreSQL (Docker)** | 2 min | ✅ Fast | ✅ Yes (volume-backed) | Development with real data |
| **PostgreSQL (Local)** | 10 min | ✅ Fast | ✅ Yes (on disk) | Production-like environment |

### Option 1: View Data with PgAdmin (Docker Mode)

When running `docker-compose up`:

1. Open http://localhost:5050
2. Login with:
   - Email: `admin@medical.local`
   - Password: `admin`
3. Add a new server:
   - Host: `postgres` (or `host.docker.internal` on Mac/Windows)
   - Port: `5432`
   - Username: `medical_user`
   - Password: `medical_password`
   - Database: `medical_insurance`

### Option 2: Query Database from Command Line

**Using Docker:**
```bash
docker-compose exec postgres psql -U medical_user -d medical_insurance
```

**Using local PostgreSQL:**
```bash
psql -U medical_user -d medical_insurance -h localhost
```

### Option 3: Useful Database Queries

```sql
-- List all tables
\dt

-- View policies
SELECT * FROM policies;

-- View claims
SELECT * FROM claims;

-- View users
SELECT id, email, user_type FROM users;

-- Check database size
SELECT pg_database.datname, pg_size_pretty(pg_database_size(pg_database.datname)) 
FROM pg_database;
```

---

## Troubleshooting

### Docker Compose Issues

**Port already in use:**
```bash
# Find and stop the process using the port
lsof -i :8001  # For intranet site (port 8001)
lsof -i :8002  # For internet site (port 8002)
lsof -i :5432  # For PostgreSQL (port 5432)

# Kill the process
kill -9 <PID>

# Or change the port in docker-compose.yml
```

**Database connection errors:**
```bash
# Check if postgres is healthy
docker-compose ps

# View postgres logs
docker-compose logs postgres

# Wait for postgres to be ready, then restart apps
docker-compose restart intranet-site internet-site
```

**Rebuild containers with fresh dependencies:**
```bash
# Remove containers and volumes
docker-compose down -v

# Rebuild and restart
docker-compose up --build -d
```

### Python Environment Issues

**Virtual environment not working:**
```bash
# Try removing and recreating
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

**PostgreSQL connection issues (local setup):**
```bash
# Check if PostgreSQL is running
brew services list

# Start PostgreSQL if not running
brew services start postgresql

# Check PostgreSQL is listening
lsof -i :5432
```

---

## Development Workflow

### Run Tests

```bash
# Internet Site Tests
cd internet-site
python -m pytest tests/ -v

# Intranet Site Tests
cd intranet-site
python -m pytest tests/ -v
```

### Run Linting and Formatting

```bash
# Install development tools
pip install black flake8 mypy

# Format code
black app/ tests/

# Check code quality
flake8 app/ tests/
mypy app/
```

### Rebuild Docker Images

```bash
cd infra
docker-compose build --no-cache
docker-compose up -d
```

---

## Environment Variables Reference

### Intranet Site (`intranet-site/.env`)
- `APP_NAME` - Application identifier
- `ENVIRONMENT` - Deployment environment (development/production)
- `LOG_LEVEL` - Logging level (DEBUG/INFO/WARNING/ERROR)
- `ALLOWED_ORIGINS` - CORS allowed origins
- `DATABASE_URL` - PostgreSQL connection string
- `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` - Database connection details

### Internet Site (`internet-site/.env`)
- Same as Intranet Site

---

## 📊 Setup Methods Comparison

| Method | Setup Time | Docker? | Database | Startup Time | Data Persist | Use Case |
|--------|-----------|---------|----------|-------------|--------------|----------|
| **Docker + PostgreSQL** | 2 min | ✅ Yes | PostgreSQL | 10-15s | ✅ Yes (volume) | Production-like dev |
| **Docker + SQLite** | 1 min | ✅ Yes | SQLite (in-memory) | 2-5s | ❌ No | Fast testing/TDD |
| **Native Python (SQLite)** | 1 min | ❌ No | SQLite (in-memory) | 2-3s | ❌ No | Quick prototyping |
| **Native Python (PostgreSQL)** | 5 min | Partial | PostgreSQL (Docker) | 5-10s | ✅ Yes (Docker) | Development with real data |
| **Native Python (Local PostgreSQL)** | 10 min | ❌ No | PostgreSQL (local) | 3-5s | ✅ Yes (disk) | Full native environment |

---

## 📋 Common Commands

### Start Services

| Command | What It Does |
|---------|------------|
| `make up` | Docker with PostgreSQL (recommended) |
| `make up-memory` | Docker with in-memory SQLite |
| `make dev-intranet` | Native Python intranet site |
| `make dev-internet` | Native Python internet site |
| `make down` | Stop all services (keep data) |
| `make down-clean` | Stop all services (delete all data) |

### Monitor Services

| Command | What It Does |
|---------|------------|
| `make logs` | View all service logs |
| `make logs-intranet` | View intranet logs |
| `make logs-internet` | View internet logs |
| `make logs-db` | View database logs |
| `make status` | Check service status |

### Testing & Development

| Command | What It Does |
|---------|------------|
| `make test` | Run all tests |
| `make test-intranet` | Run intranet tests |
| `make test-internet` | Run internet tests |
| `make lint` | Run code linting |
| `make format` | Format code with black |

---

## 🎯 Recommended Setup by Role

### Backend Developer
```bash
# Start everything with PostgreSQL
make up

# Monitor logs
make logs

# Edit code and auto-reload happens with --reload flag
```

### Frontend Developer (Using APIs)
```bash
# Quick start with fast in-memory database
make up-memory

# Or use native Python for fastest startup
make dev-intranet && make dev-internet
```

### QA/Tester
```bash
# Use multiple setups to test database compatibility
make up              # Test with PostgreSQL
make up-memory       # Test with in-memory SQLite
```

### DevOps/Architect
```bash
# Review setup
cat LOCAL_DEVELOPMENT.md
cat DATABASE_OPTIONS.md
cat IMIC_DATABASE_DESIGN.md
```

---

## 🆘 When Something Goes Wrong

### Services won't start
```bash
# Check what's using the ports
lsof -i :8001  # intranet
lsof -i :8002  # internet
lsof -i :5432  # database

# Kill processes and try again
make down-clean
make up
```

### Database connection fails
```bash
# Restart just the database
docker-compose -f infra/docker-compose.yml restart postgres

# Or restart everything
make down && make up
```

### Python dependencies issue
```bash
# Reinstall dependencies
cd intranet-site && pip install -r requirements.txt --force-reinstall
cd ../internet-site && pip install -r requirements.txt --force-reinstall
```

### Docker issues
```bash
# Full cleanup and restart
make down-clean
docker system prune -a
make up --build
```

---

## 📚 Learn More

- **DATABASE_OPTIONS.md** - Detailed comparison of database options
- **IN_MEMORY_DB.md** - In-memory SQLite setup guide
- **IMIC_DATABASE_DESIGN.md** - Production database schema
- **START_HERE.md** - Quick overview of the project
- **DOCUMENTATION_INDEX.md** - Navigation guide for all documentation
````

---

## Next Steps

1. Test API endpoints using curl or Postman:
   ```bash
   curl http://localhost:8001/health
   curl http://localhost:8002/health
   ```

2. View API documentation:
   - Intranet: http://localhost:8001/docs
   - Internet: http://localhost:8002/docs

3. Explore the database schema in `infra/init-db.sql`

4. Modify the apps in `intranet-site/app/main.py` and `internet-site/app/main.py`

---

## Additional Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [PgAdmin Documentation](https://www.pgadmin.org/)
