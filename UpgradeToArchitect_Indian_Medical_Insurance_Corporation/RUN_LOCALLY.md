# Running Both Sites Locally with PostgreSQL Database

## Overview

You now have a complete local development environment with:
- ✅ PostgreSQL database (persistent local storage)
- ✅ PgAdmin web UI for database management
- ✅ Intranet site (port 8001)
- ✅ Internet site (port 8002)
- ✅ Both sites connected to the same database
- ✅ Docker Compose orchestration

---

## Prerequisites

**Required:**
- Docker Desktop ([download here](https://www.docker.com/products/docker-desktop))
- macOS, Windows, or Linux

**Optional (for Python development without Docker):**
- Python 3.9+
- PostgreSQL client tools

---

## Quick Start (1 minute)

### Using Automated Setup Script

```bash
cd /Users/adorajade/Playground/Upgrade2Architect/medical-insurance-app
./scripts/local-dev-setup.sh
```

This will:
1. ✅ Verify Docker is installed
2. ✅ Start all containers
3. ✅ Wait for services to be ready
4. ✅ Display access URLs and credentials

### Or Start Manually

```bash
cd /Users/adorajade/Playground/Upgrade2Architect/medical-insurance-app/infra
docker-compose up -d
```

Wait ~10 seconds for all services to start.

---

## Access Your Services

Once running, you can access:

### 🌐 Internet Site (Public Portal)
- **API**: http://localhost:8002
- **API Docs**: http://localhost:8002/docs
- **OpenAPI**: http://localhost:8002/openapi.json

### 🏢 Intranet Site (Employee Portal)
- **API**: http://localhost:8001
- **API Docs**: http://localhost:8001/docs
- **OpenAPI**: http://localhost:8001/openapi.json

### 🗄️ PostgreSQL Database
- **Host**: `localhost`
- **Port**: `5432`
- **Database**: `medical_insurance`
- **User**: `medical_user`
- **Password**: `medical_password`

### 🔧 PgAdmin (Database Management UI)
- **URL**: http://localhost:5050
- **Email**: `admin@medical.local`
- **Password**: `admin`

---

## Test the APIs

### Test Internet Site Health
```bash
curl http://localhost:8002/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2026-02-26T...",
  "service": "internet-site",
  "version": "1.0.0"
}
```

### Test Intranet Site Health
```bash
curl http://localhost:8001/health
```

### View API Documentation
Open in browser:
- Intranet Docs: http://localhost:8001/docs
- Internet Docs: http://localhost:8002/docs

These are interactive Swagger UI interfaces where you can test endpoints directly.

---

## Common Operations

### View Logs

View all services:
```bash
cd infra
docker-compose logs -f
```

View specific service:
```bash
docker-compose logs -f intranet-site
docker-compose logs -f internet-site
docker-compose logs -f postgres
```

### Stop Services

Keep data:
```bash
cd infra
docker-compose down
```

Remove all data:
```bash
cd infra
docker-compose down -v
```

### Restart Services

Restart everything:
```bash
cd infra
docker-compose restart
```

Restart specific service:
```bash
cd infra
docker-compose restart intranet-site
```

### Check Service Status

```bash
cd infra
docker-compose ps
```

---

## Database Management

### Access PostgreSQL CLI

Via Docker:
```bash
docker-compose exec postgres psql -U medical_user -d medical_insurance
```

Useful commands in psql:
```sql
-- List all tables
\dt

-- View users table
SELECT * FROM users;

-- View policies
SELECT * FROM policies;

-- View claims
SELECT * FROM claims;

-- View schema
\d table_name

-- Exit
\q
```

### Use PgAdmin Web UI

1. Open http://localhost:5050
2. Login with:
   - Email: `admin@medical.local`
   - Password: `admin`
3. Add a new server:
   - **Name**: Medical DB
   - **Host**: `postgres` (or `host.docker.internal` on Mac/Windows)
   - **Port**: `5432`
   - **Username**: `medical_user`
   - **Password**: `medical_password`
4. Browse tables and run queries

### View Database Schema

The database schema is in `infra/init-db.sql`:

**Tables:**
- `users` - User accounts
- `policies` - Insurance policies
- `claims` - Insurance claims
- `employees` - Employee information (intranet)
- `audit_logs` - Change tracking

---

## Developing with the Local Setup

### Using the Python Sites Directly

Both sites use FastAPI with hot-reload enabled. When you edit code in:
- `intranet-site/app/main.py`
- `internet-site/app/main.py`

The running servers will automatically reload with your changes.

### Adding Dependencies

If you need to add Python packages:

1. Update the requirements file:
   ```bash
   echo "new-package==1.0.0" >> intranet-site/requirements.txt
   ```

2. Rebuild the Docker image:
   ```bash
   cd infra
   docker-compose build --no-cache intranet-site
   docker-compose restart intranet-site
   ```

### Running Tests

Tests are in the `tests/` directories:

```bash
# Internet site tests
docker-compose exec internet-site python -m pytest tests/ -v

# Intranet site tests
docker-compose exec intranet-site python -m pytest tests/ -v
```

---

## Environment Variables

Both sites have `.env.example` files showing available configuration:

**Key variables:**
- `APP_NAME` - Application identifier
- `ENVIRONMENT` - development/production
- `LOG_LEVEL` - DEBUG/INFO/WARNING/ERROR
- `ALLOWED_ORIGINS` - CORS allowed origins
- `DATABASE_URL` - PostgreSQL connection string
- `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` - Database details

These are automatically configured in `docker-compose.yml`.

---

## Troubleshooting

### Ports Already in Use

```bash
# Find what's using the port
lsof -i :8001        # Intranet
lsof -i :8002        # Internet
lsof -i :5432        # PostgreSQL
lsof -i :5050        # PgAdmin

# Kill the process
kill -9 <PID>
```

### Services Won't Start

```bash
# Check logs
docker-compose logs

# Restart Docker Desktop if on macOS/Windows

# Remove containers and try again
docker-compose down -v
docker-compose up -d
```

### Database Connection Errors

```bash
# Check if postgres is healthy
docker-compose ps

# View postgres logs
docker-compose logs postgres

# Restart postgres
docker-compose restart postgres
```

### Can't Connect from Host to Database

On Docker Desktop for Mac/Windows, use:
- Host: `host.docker.internal` instead of `localhost` (in some tools)
- Port: `5432`

### Containers Keep Restarting

```bash
# Check logs for errors
docker-compose logs -f

# Rebuild images
docker-compose build --no-cache
docker-compose up -d
```

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────┐
│         Docker Compose Network                   │
│                                                   │
│  ┌──────────────┐    ┌──────────────┐           │
│  │  Intranet    │    │   Internet    │           │
│  │   (8001)     │    │   (8002)      │           │
│  └──────┬───────┘    └──────┬────────┘           │
│         │                    │                    │
│         └────────┬───────────┘                    │
│                  │                                │
│         ┌────────▼─────────┐                     │
│         │   PostgreSQL     │                     │
│         │   Database       │                     │
│         │   (5432)         │                     │
│         └─────────────────┘                      │
│                                                   │
│         ┌─────────────────────┐                  │
│         │     PgAdmin UI      │                  │
│         │     (5050)          │                  │
│         └─────────────────────┘                  │
│                                                   │
└─────────────────────────────────────────────────┘
```

---

## File Structure

```
medical-insurance-app/
├── infra/
│   ├── docker-compose.yml         ← Main config for local dev
│   ├── init-db.sql                ← Database schema
│   ├── main.bicep                 ← Azure infrastructure
│   └── ...
├── internet-site/
│   ├── app/main.py                ← Internet site code
│   ├── requirements.txt            ← Python dependencies
│   ├── Dockerfile                  ← Docker build config
│   ├── tests/                      ← Tests
│   └── .env.example                ← Environment template
├── intranet-site/
│   ├── app/main.py                ← Intranet site code
│   ├── requirements.txt            ← Python dependencies
│   ├── Dockerfile                  ← Docker build config
│   ├── tests/                      ← Tests
│   └── .env.example                ← Environment template
├── scripts/
│   ├── local-dev-setup.sh          ← Automated setup
│   └── ...
├── LOCAL_DEVELOPMENT.md            ← Detailed guide
├── LOCAL_SETUP_SUMMARY.md          ← Quick summary
└── README.md                       ← Main README
```

---

## Next Steps

1. ✅ Run the setup script or `docker-compose up -d`
2. ✅ Open http://localhost:8001/docs (Intranet)
3. ✅ Open http://localhost:8002/docs (Internet)
4. ✅ Try out the API endpoints in the Swagger UI
5. ✅ Visit http://localhost:5050 for database management
6. ✅ Start developing!

---

## Support & Documentation

- **Local Development Guide**: `LOCAL_DEVELOPMENT.md` (comprehensive)
- **Setup Summary**: `LOCAL_SETUP_SUMMARY.md` (quick reference)
- **Database Schema**: `infra/init-db.sql`
- **Docker Compose**: `infra/docker-compose.yml`
- **FastAPI Docs**: https://fastapi.tiangolo.com/
- **Docker Compose Docs**: https://docs.docker.com/compose/

---

## Summary

You now have:
- ✅ PostgreSQL database running locally
- ✅ Both sites connected to the same database
- ✅ Automated setup script for quick starts
- ✅ PgAdmin UI for database management
- ✅ Hot-reload development experience
- ✅ Complete development environment

**Start with**: `./scripts/local-dev-setup.sh`

Happy coding! 🚀
