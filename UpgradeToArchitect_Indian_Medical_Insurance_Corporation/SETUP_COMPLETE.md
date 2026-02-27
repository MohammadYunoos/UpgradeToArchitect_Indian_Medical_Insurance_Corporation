# Local Database & Multi-Site Setup - Implementation Summary

## ✅ What Was Added

Your medical insurance app now supports **local development with a shared PostgreSQL database** and **both sites running together**!

---

## 📁 Files Created/Updated

### New Files:

1. **`infra/init-db.sql`** 
   - Complete PostgreSQL database schema
   - Tables: users, policies, claims, employees, audit_logs
   - Indexes, constraints, and initial permissions

2. **`LOCAL_DEVELOPMENT.md`**
   - Comprehensive 200+ line development guide
   - Setup instructions for Docker and Python
   - Database management and troubleshooting
   - Development workflow and environment variables

3. **`LOCAL_SETUP_SUMMARY.md`**
   - Quick reference guide
   - Service URLs and credentials
   - Common tasks
   - Troubleshooting tips

4. **`RUN_LOCALLY.md`**
   - Complete guide to running everything locally
   - API testing instructions
   - Architecture diagram
   - Quick start section

5. **`scripts/local-dev-setup.sh`**
   - Automated setup script
   - Checks for Docker prerequisites
   - Starts all services
   - Displays URLs and credentials
   - Made executable with proper permissions

6. **`Makefile`**
   - Convenient commands for common tasks
   - 30+ make targets
   - Help documentation

### Updated Files:

1. **`infra/docker-compose.yml`**
   - Added PostgreSQL 15 service
   - Added PgAdmin service
   - Added database volume for persistence
   - Added health checks
   - Updated app configurations with database environment variables
   - Created shared medical-network

2. **`internet-site/requirements.txt`**
   - Added SQLAlchemy 2.0.23 (ORM)
   - Added psycopg2-binary 2.9.9 (PostgreSQL driver)
   - Added Alembic 1.12.1 (migrations)
   - Added testing libraries (pytest, httpx)

3. **`intranet-site/requirements.txt`**
   - Added SQLAlchemy 2.0.23 (ORM)
   - Added psycopg2-binary 2.9.9 (PostgreSQL driver)
   - Added Alembic 1.12.1 (migrations)
   - Added testing libraries (pytest, httpx)

4. **`internet-site/.env.example`**
   - Updated with PostgreSQL configuration
   - Added all database connection variables
   - Improved clarity with comments

5. **`intranet-site/.env.example`**
   - Updated with PostgreSQL configuration
   - Added all database connection variables
   - Improved clarity with comments

---

## 🚀 Quick Start

```bash
# Option 1: Automated (Recommended)
./scripts/local-dev-setup.sh

# Option 2: Manual
cd infra
docker-compose up -d
```

---

## 🌐 Service URLs

| Service | URL | Type |
|---------|-----|------|
| Internet Site | http://localhost:8002 | API |
| Internet Docs | http://localhost:8002/docs | Swagger UI |
| Intranet Site | http://localhost:8001 | API |
| Intranet Docs | http://localhost:8001/docs | Swagger UI |
| PgAdmin | http://localhost:5050 | Database UI |
| PostgreSQL | localhost:5432 | Database |

---

## 🗄️ Database

**PostgreSQL 15 (Alpine Linux)**
- **Credentials**: `medical_user` / `medical_password`
- **Database**: `medical_insurance`
- **Port**: 5432
- **Persistence**: Data saved in Docker volume
- **Schema**: Complete with 5 tables + indexes

**Tables:**
- `users` - User accounts (employee/customer/admin)
- `policies` - Insurance policies
- `claims` - Insurance claims
- `employees` - Employee information
- `audit_logs` - Change tracking

---

## 🔧 Make Commands

Convenient shortcuts for common tasks:

```bash
make help              # Show all commands
make setup             # Automated setup
make up                # Start services
make down              # Stop services
make logs              # View all logs
make logs-intranet     # View intranet logs
make logs-internet     # View internet logs
make logs-db           # View database logs
make restart           # Restart all services
make db-shell          # Open PostgreSQL shell
make test              # Run tests
make status            # Check service status
```

---

## 📋 Architecture

```
Docker Compose Network
├── PostgreSQL (5432)
│   └── Persistent volume with medical_insurance database
├── PgAdmin (5050)
│   └── Web UI for database management
├── Intranet Site (8001)
│   └── FastAPI app + database connection
└── Internet Site (8002)
    └── FastAPI app + database connection
```

---

## 🔑 Key Features

✅ **Local PostgreSQL Database**
- Persistent data storage
- Shared between both sites
- Full schema with relationships

✅ **Both Sites Running Together**
- Intranet on port 8001
- Internet on port 8002
- Both connected to same database

✅ **PgAdmin Database UI**
- Visual database management
- Query builder
- Web-based interface

✅ **Automated Setup**
- One-command startup script
- Checks prerequisites
- Displays all URLs

✅ **Complete Documentation**
- 4 detailed guides
- Quick reference
- Troubleshooting tips

✅ **Development Tools**
- Hot-reload support
- Test frameworks included
- Database migrations ready (Alembic)

---

## 📚 Documentation Files

1. **`RUN_LOCALLY.md`** - START HERE
   - Complete local setup guide
   - API testing instructions
   - Architecture diagram

2. **`LOCAL_DEVELOPMENT.md`** - Comprehensive reference
   - Detailed setup steps
   - Python-only development
   - Database management
   - Troubleshooting

3. **`LOCAL_SETUP_SUMMARY.md`** - Quick reference
   - File changes summary
   - Common tasks
   - Credentials reminder

4. **`Makefile`** - Command shortcuts
   - 30+ convenient commands
   - Self-documenting (make help)

---

## 🛠️ Development Workflow

### Using Docker Compose (Recommended)
```bash
./scripts/local-dev-setup.sh
# Make code changes
# Servers auto-reload
make logs  # View any issues
make down  # Stop when done
```

### Using Python Directly
```bash
make venv           # Create virtual environments
make install-deps   # Install dependencies
make dev-intranet   # Run intranet (terminal 1)
make dev-internet   # Run internet (terminal 2)
```

---

## 🧪 Testing

```bash
make test           # Run all tests
make test-intranet  # Test intranet only
make test-internet  # Test internet only
```

---

## 🐛 Troubleshooting

**Port in use?**
```bash
lsof -i :8001
kill -9 <PID>
```

**Database won't start?**
```bash
make logs-db
make db-reset
```

**Need fresh start?**
```bash
make down-clean
make up
```

---

## 📖 What's Next?

1. ✅ Run the setup: `./scripts/local-dev-setup.sh`
2. ✅ Test the APIs: 
   - http://localhost:8001/docs
   - http://localhost:8002/docs
3. ✅ Explore the database: http://localhost:5050
4. ✅ Start developing!

---

## 💡 Notes

- All Docker data persists in volumes (survives restart)
- Use `make down -clean` to reset everything
- Environment variables auto-loaded from docker-compose.yml
- Both sites share the same PostgreSQL instance
- Hot-reload works for Python code changes
- Database migrations ready with Alembic

---

## 📞 Support

All questions answered in:
- `RUN_LOCALLY.md` - Start here
- `LOCAL_DEVELOPMENT.md` - Detailed guide  
- Run `make help` - See all commands

Happy coding! 🎉
