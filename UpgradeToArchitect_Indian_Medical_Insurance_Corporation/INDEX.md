# Medical Insurance App - Local Development Setup Complete

## 🎯 You Now Have:

✅ **Local PostgreSQL Database** - Persistent storage for development  
✅ **Both Sites Running Together** - Internet (8002) + Intranet (8001)  
✅ **Database Management UI** - PgAdmin for visual database browsing  
✅ **One-Command Setup** - Automated script that verifies everything  
✅ **Hot-Reload Development** - Code changes auto-reload in browser  
✅ **Complete Documentation** - 4+ comprehensive guides  
✅ **Make Commands** - 30+ convenient shortcuts  

---

## 🚀 To Get Started Right Now

Choose your preferred method (all do the same thing):

### Method 1: Automated Setup Script (Easiest - Recommended)
```bash
./scripts/local-dev-setup.sh
```
Takes ~15 seconds, checks prerequisites, starts all services, shows you the URLs.

### Method 2: Using Make
```bash
make setup    # Automated version
# OR
make up       # Just start the services
```

### Method 3: Manual Docker Compose
```bash
cd infra
docker-compose up -d
```

Then wait ~10 seconds for everything to start.

---

## 📖 Where to Find Information

### 📌 Start Here
**→ `START_HERE.md`** - This comprehensive overview (what's new, quick start, URLs)

### 🚀 To Run Everything
**→ `RUN_LOCALLY.md`** - Complete guide with:
- Quick start instructions
- Service URLs & credentials
- Testing the APIs
- Troubleshooting

### 📚 For Detailed Reference
**→ `LOCAL_DEVELOPMENT.md`** - 200+ line comprehensive guide with:
- Setup without Docker (Python only)
- Database management
- Development workflow
- All environment variables
- Detailed troubleshooting

### ⚡ For Quick Commands
**→ `Makefile`** - Run `make help` to see 30+ commands

---

## 🌐 What URLs Will You Have?

After running the startup script/commands:

| Service | URL | What It Is |
|---------|-----|-----------|
| **Intranet API** | http://localhost:8001 | The intranet site |
| **Intranet Docs** | http://localhost:8001/docs | Interactive API docs |
| **Internet API** | http://localhost:8002 | The internet site |
| **Internet Docs** | http://localhost:8002/docs | Interactive API docs |
| **PgAdmin** | http://localhost:5050 | Database management |
| **PostgreSQL** | localhost:5432 | Database server |

**PgAdmin login:** `admin@medical.local` / `admin`  
**Database login:** `medical_user` / `medical_password`

---

## 💾 Your Database

PostgreSQL 15 with these tables:
- **users** - User accounts (employee, customer, admin)
- **policies** - Insurance policies
- **claims** - Insurance claims
- **employees** - Employee information
- **audit_logs** - Change tracking

Data persists even when you stop the containers!

---

## 🛠️ Common Commands

```bash
# Start everything
./scripts/local-dev-setup.sh
make setup
make up

# Stop everything
make down                  # Keep data
make down-clean           # Remove all data

# View what's happening
make logs                 # All services
make logs-intranet       # Just intranet
make logs-internet       # Just internet
make logs-db             # Just database

# Manage database
make db-shell            # Open database CLI
make db-reset            # Reset to clean state

# Run tests
make test                # Run all tests
make test-intranet      # Intranet only
make test-internet      # Internet only

# See all commands
make help
```

---

## 📁 Files That Were Changed

### New Files Created:
- `infra/init-db.sql` - Database schema
- `LOCAL_DEVELOPMENT.md` - Comprehensive guide
- `LOCAL_SETUP_SUMMARY.md` - Quick reference
- `RUN_LOCALLY.md` - Complete setup guide
- `SETUP_COMPLETE.md` - Implementation summary
- `START_HERE.md` - Quick overview (← read this!)
- `scripts/local-dev-setup.sh` - Automated setup
- `scripts/verify-setup.sh` - Verify installation
- `Makefile` - Command shortcuts

### Files Updated:
- `infra/docker-compose.yml` - Added PostgreSQL + PgAdmin
- `internet-site/requirements.txt` - Added database libraries
- `intranet-site/requirements.txt` - Added database libraries
- `internet-site/.env.example` - Added database config
- `intranet-site/.env.example` - Added database config

---

## 🏗️ Architecture

```
Your Computer
├── Docker Compose (manages everything)
│   ├── PostgreSQL 15
│   │   └── persistent_volume (your data)
│   ├── PgAdmin (web UI for database)
│   ├── Intranet Site (port 8001)
│   └── Internet Site (port 8002)
└── (Both sites connected to same database)
```

---

## ✨ Key Features

✅ **Shared Database** - Both sites read/write to same PostgreSQL  
✅ **Persistent Data** - Database data survives container restarts  
✅ **PgAdmin UI** - Visual database browser (no CLI needed)  
✅ **Auto Reload** - Edit Python code, browser auto-updates  
✅ **Hot Reload** - Changes take effect immediately  
✅ **Docker Compose** - All services orchestrated together  
✅ **Isolated Network** - All services on isolated docker network  

---

## 🎯 Next Steps

1. **Run the setup:**
   ```bash
   ./scripts/local-dev-setup.sh
   ```

2. **Wait for services to start** (~10 seconds)

3. **Test the APIs:**
   - Open http://localhost:8001/docs (Intranet)
   - Open http://localhost:8002/docs (Internet)
   - Try some API endpoints in the Swagger UI

4. **Explore the database:**
   - Visit http://localhost:5050 (PgAdmin)
   - Login with admin@medical.local / admin
   - Browse tables and data

5. **Start developing:**
   - Edit `intranet-site/app/main.py`
   - Edit `internet-site/app/main.py`
   - Changes auto-reload!

6. **When you're done:**
   ```bash
   make down          # Stop but keep data
   # or
   make down-clean    # Stop and remove everything
   ```

---

## ❓ Common Questions

**Q: Do I need Python installed?**  
A: No! Docker includes everything. (Optional if you want to run apps directly)

**Q: Will my database data disappear?**  
A: No! Data persists in Docker volume. Use `make down-clean` to remove.

**Q: How do I stop everything?**  
A: `make down` (services stop, data stays) or `make down-clean` (everything removed)

**Q: Can I access the database from my computer?**  
A: Yes! Use `localhost:5432` with database tool, or `make db-shell` for CLI

**Q: Why are there two sites?**  
A: Internet = public portal, Intranet = internal staff portal

**Q: Can I use these sites for production?**  
A: No, this is local dev only. See `infra/azure-deployment.md` for production

---

## 📚 Documentation Reference

**File** | **Purpose** | **Length** | **For**
---------|-----------|-----------|-------
`START_HERE.md` | This file - quick overview | Short | Getting started
`RUN_LOCALLY.md` | Complete local setup | Medium | Running everything
`LOCAL_DEVELOPMENT.md` | Detailed guide | Long | Deep dives
`LOCAL_SETUP_SUMMARY.md` | Quick reference | Short | Quick lookups
`Makefile` | Command shortcuts | - | See with `make help`

---

## 🆘 Troubleshooting

**Services won't start?**
```bash
make down-clean    # Remove everything
make up            # Start fresh
make logs          # Check what went wrong
```

**Port already in use?**
```bash
lsof -i :8001      # Find what's using port
kill -9 <PID>      # Kill it
```

**Database won't connect?**
```bash
make logs-db       # Check database logs
make db-shell      # Try to connect directly
make db-reset      # Reset database
```

---

## 📞 Need More Help?

Everything is documented:

1. **For quick overview**: Read this file (you're here!)
2. **For how to run**: Open `RUN_LOCALLY.md`
3. **For detailed help**: Open `LOCAL_DEVELOPMENT.md`
4. **For commands**: Run `make help`
5. **To verify setup**: Run `./scripts/verify-setup.sh`

---

## 🎉 You're Ready!

Your local development environment is fully set up! 

**To start:** `./scripts/local-dev-setup.sh`

**Then visit:**
- http://localhost:8001/docs (Intranet)
- http://localhost:8002/docs (Internet)
- http://localhost:5050 (Database UI)

Happy coding! 🚀

---

**Last Updated:** February 26, 2026  
**Status:** ✅ Complete and Ready to Use
