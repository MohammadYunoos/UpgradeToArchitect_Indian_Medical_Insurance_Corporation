# Local Startup Scripts

This directory contains scripts to easily start the Medical Insurance application locally **without Docker**.

## Quick Reference

| Script | Purpose | Docker? | Setup Time | Best For |
|--------|---------|---------|-----------|----------|
| **quick-start.sh** | One-command startup | ❌ No | 1-2 min | Quick development |
| **start-local.sh** | Flexible options | ❌ No* | 1-2 min | Custom setups |

*Optional: Docker available for postgres/memory modes

---

---

## 🚀 Quick Start (30 seconds)

```bash
./scripts/quick-start.sh
```

**What happens:**
- ✅ Installs Python dependencies
- ✅ Starts Intranet Site (http://localhost:8001)
- ✅ Starts Internet Site (http://localhost:8002)
- ✅ Uses SQLite in-memory database (ultra-fast)
- ✅ Displays all URLs and logs in real-time
- ✅ No Docker needed

---

## 📋 start-local.sh (Optional - For Docker Modes)

If you need Docker-based databases:

```bash
./scripts/start-local.sh [option]
```

### Options

| Option | What It Does | Best For |
|--------|------------|----------|
| `docker` | PostgreSQL + Docker | Production-like environment |
| `memory` | SQLite in-memory + Docker | Fast testing with containers |
| `native` | Pure Python setup | Complete native environment |
| `help` | Show help | See all options |

### Examples

```bash
# Native Python (no Docker) - RECOMMENDED
./scripts/quick-start.sh

# Or with more options
./scripts/start-local.sh native      # Pure Python

# Optional: With Docker
./scripts/start-local.sh docker      # PostgreSQL + Docker
./scripts/start-local.sh memory      # In-memory SQLite
```

---

## 📊 Detailed Comparison

### quick-start.sh (RECOMMENDED - NO DOCKER!)
**Best for:** Getting started immediately

```bash
./scripts/quick-start.sh
```

**Startup sequence:**
1. Check Python 3
2. Check ports 8001, 8002
3. Install dependencies (1-2 min first time)
4. Start Intranet Site → port 8001
5. Start Internet Site → port 8002
6. Display URLs and logs

**Features:**
- ✅ Simplest option
- ✅ **No Docker needed**
- ✅ Auto-reload on code changes
- ✅ In-memory database (ultra-fast)
- ✅ Logs to stdout
- ✅ Graceful shutdown with Ctrl+C

**Access:**
- Intranet: http://localhost:8001
- Internet: http://localhost:8002
- Docs: http://localhost:8001/docs & http://localhost:8002/docs

---

### start-local.sh docker (Optional)
**Best for:** Production-like local development with persistent database

```bash
./scripts/start-local.sh docker
```

**Startup sequence:**
1. Check Docker installation
2. Check Docker is running
3. Check ports availability
4. Start Docker Compose services:
   - PostgreSQL (localhost:5432)
   - PgAdmin (http://localhost:5050)
   - Intranet Site (http://localhost:8001)
   - Internet Site (http://localhost:8002)
5. Wait for services to be healthy
6. Display credentials and URLs
7. Stream logs to console

**Features:**
- ✅ PostgreSQL database (persistent)
- ✅ PgAdmin UI for database management
- ✅ Realistic production-like environment
- ✅ Volume-backed data persistence
- ✅ Health checks
- ✅ Full Docker isolation

**Access:**
- Intranet: http://localhost:8001
- Internet: http://localhost:8002
- Docs: http://localhost:8001/docs & http://localhost:8002/docs
- PgAdmin: http://localhost:5050
- PostgreSQL: localhost:5432

**Credentials:**
```
PostgreSQL:
  User: medical_user
  Password: medical_password
  Database: medical_insurance

PgAdmin:
  Email: admin@medical.local
  Password: admin
```

---

### start-local.sh memory
**Best for:** Fast testing without persistence

```bash
./scripts/start-local.sh memory
```

**Startup sequence:**
1. Check Docker installation
2. Check Docker is running
3. Check ports availability
4. Start Docker Compose with in-memory SQLite
5. Display URLs and information
6. Stream logs to console

**Features:**
- ✅ Docker isolation
- ✅ Ultra-fast startup (2-5 seconds)
- ✅ In-memory database (no persistence)
- ✅ Health checks
- ✅ Perfect for testing

**Access:**
- Intranet: http://localhost:8001
- Internet: http://localhost:8002
- Docs: http://localhost:8001/docs & http://localhost:8002/docs

---

### start-local.sh native
**Best for:** Pure Python development

```bash
./scripts/start-local.sh native
```

**Setup sequence:**
1. Check Python installation
2. Check ports availability
3. Create virtual environments (if needed)
4. Install dependencies
5. Display instructions for two terminals

**Manual execution:**
After setup, run in separate terminals:

```bash
# Terminal 1
cd intranet-site
source venv/bin/activate
uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload

# Terminal 2
cd internet-site
source venv/bin/activate
uvicorn app.main:app --host 0.0.0.0 --port 8002 --reload
```

**Features:**
- ✅ No Docker required
- ✅ Full Python control
- ✅ Virtual environments
- ✅ Auto-reload on code changes
- ✅ Best for Python development

**Access:**
- Intranet: http://localhost:8001
- Internet: http://localhost:8002
- Docs: http://localhost:8001/docs & http://localhost:8002/docs

---

## 📌 Troubleshooting

### "Port already in use"
```bash
# Find what's using the port
lsof -i :8001
lsof -i :8002

# Kill the process
kill -9 <PID>

# Or change ports in docker-compose.yml
```

### "Docker is not running"
```bash
# Start Docker Desktop
# macOS: open /Applications/Docker.app

# Or verify Docker is running
docker ps
```

### "Python not found"
```bash
# Install Python 3.9+
# macOS: brew install python@3.9
# Ubuntu: sudo apt-get install python3.9
# Windows: https://www.python.org/downloads/

# Verify
python3 --version
```

### "Dependencies installation fails"
```bash
# Clear pip cache and reinstall
pip cache purge
pip install -r internet-site/requirements.txt --force-reinstall
pip install -r intranet-site/requirements.txt --force-reinstall
```

### "Services won't start"
```bash
# Stop everything
docker-compose down -v
docker system prune -a

# Try again
./scripts/start-local.sh docker
```

---

## 🆚 Which Script Should I Use?

### I want to develop quickly
→ Use `quick-start.sh`

### I need a realistic environment
→ Use `./scripts/start-local.sh docker`

### I want the fastest possible startup
→ Use `./scripts/start-local.sh memory`

### I prefer native Python without Docker
→ Use `./scripts/start-local.sh native`

### I want to see help
→ Use `./scripts/start-local.sh help`

---

## 📝 Logs and Monitoring

### View logs in real-time

**With quick-start.sh:**
```bash
# Logs appear in the terminal automatically
# Or check files:
tail -f /tmp/intranet.log
tail -f /tmp/internet.log
```

**With start-local.sh (Docker modes):**
```bash
# Logs appear in the terminal automatically
# Or in another terminal:
docker-compose -f infra/docker-compose.yml logs -f
docker-compose -f infra/docker-compose.yml logs -f intranet-site
docker-compose -f infra/docker-compose.yml logs -f internet-site
docker-compose -f infra/docker-compose.yml logs -f postgres
```

---

## 🛑 Stopping Services

### With quick-start.sh or start-local.sh
```bash
# Press Ctrl+C in the terminal running the script
# Services will shut down gracefully
```

### Cleanup after stopping
```bash
# Remove Docker containers and volumes
docker-compose down -v

# Or use Make commands
make down-clean
```

---

## 🔗 Integration with Makefile

These scripts are complementary to the Makefile commands:

```bash
# Using scripts
./scripts/quick-start.sh              # Quick start
./scripts/start-local.sh docker       # Full Docker setup

# Using Makefile
make up                               # Docker with PostgreSQL
make up-memory                        # Docker with in-memory
make dev-intranet                     # Native Python intranet
make dev-internet                     # Native Python internet
make down                             # Stop services
make logs                             # View logs
```

---

## 📚 More Information

- **LOCAL_DEVELOPMENT.md** - Comprehensive development guide
- **DATABASE_OPTIONS.md** - Database comparison
- **IN_MEMORY_DB.md** - In-memory SQLite details
- **DOCUMENTATION_INDEX.md** - Complete documentation index
- **Makefile** - Additional automation commands

---

## ✨ Features Summary

| Feature | quick-start | docker | memory | native |
|---------|-------------|--------|--------|--------|
| Setup time | 1-2 min | 2 min | 1 min | 2 min |
| Docker required | ❌ No | ✅ Yes | ✅ Yes | ❌ No |
| Database | SQLite | PostgreSQL | SQLite | SQLite |
| Persistence | ❌ No | ✅ Yes | ❌ No | ❌ No |
| Speed | ⚡ Fast | ✅ OK | ⚡⚡ Ultra | ⚡ Fast |
| PgAdmin UI | ❌ No | ✅ Yes | ❌ No | ❌ No |
| Auto-reload | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Logs in terminal | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Graceful shutdown | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |

---

Enjoy developing! 🚀
