# Local Development Setup - Summary

## What's New ✨

You now have a complete local development environment with:

1. **PostgreSQL Database** - Shared between both sites
2. **PgAdmin UI** - Database management web interface
3. **Intranet Site** - Running on `http://localhost:8001`
4. **Internet Site** - Running on `http://localhost:8002`
5. **Automated Setup Script** - One-command startup

---

## Quick Start 🚀

### Option 1: Automated Setup (Recommended)

```bash
cd /path/to/medical-insurance-app
chmod +x scripts/local-dev-setup.sh
./scripts/local-dev-setup.sh
```

This will start all services and display access information.

### Option 2: Manual Docker Compose

```bash
cd infra
docker-compose up -d
```

Then wait ~10 seconds for services to be ready.

---

## Service URLs & Credentials

| Service | URL | Credentials |
|---------|-----|-------------|
| **Internet Site** | http://localhost:8002 | N/A |
| **Internet Docs** | http://localhost:8002/docs | N/A |
| **Intranet Site** | http://localhost:8001 | N/A |
| **Intranet Docs** | http://localhost:8001/docs | N/A |
| **PgAdmin** | http://localhost:5050 | admin@medical.local / admin |
| **PostgreSQL** | localhost:5432 | medical_user / medical_password |

---

## Database Schema

The PostgreSQL database includes:

- **users** - User accounts for both portals
- **policies** - Insurance policies
- **claims** - Insurance claims
- **employees** - Employee records for intranet
- **audit_logs** - Change tracking

See `infra/init-db.sql` for full schema details.

---

## Project Files Updated

### Modified Files:
- `infra/docker-compose.yml` - Added PostgreSQL, PgAdmin, and database environment variables
- `internet-site/requirements.txt` - Added SQLAlchemy, psycopg2, testing libraries
- `intranet-site/requirements.txt` - Added SQLAlchemy, psycopg2, testing libraries
- `internet-site/.env.example` - Updated with database configuration
- `intranet-site/.env.example` - Updated with database configuration

### New Files:
- `infra/init-db.sql` - Database schema initialization
- `LOCAL_DEVELOPMENT.md` - Comprehensive development guide
- `scripts/local-dev-setup.sh` - Automated setup script

---

## Common Tasks

### View Logs
```bash
cd infra
docker-compose logs -f intranet-site    # Intranet logs
docker-compose logs -f internet-site    # Internet logs
docker-compose logs -f postgres         # Database logs
```

### Stop All Services
```bash
cd infra
docker-compose down                     # Keep data
docker-compose down -v                  # Remove all data
```

### Access Database
```bash
# Via Docker
docker-compose exec postgres psql -U medical_user -d medical_insurance

# Or use PgAdmin at http://localhost:5050
```

### Restart a Service
```bash
cd infra
docker-compose restart intranet-site    # Specific service
docker-compose restart                  # All services
```

### Rebuild Images
```bash
cd infra
docker-compose build --no-cache
docker-compose up -d
```

---

## Development Without Docker

If you prefer to run Python apps directly:

1. **Install PostgreSQL locally** (macOS: `brew install postgresql`)
2. **Create database**: `createdb medical_insurance`
3. **Initialize schema**: `psql medical_insurance < infra/init-db.sql`
4. **For each site:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   python -m uvicorn app.main:app --reload --port <8001 or 8002>
   ```

---

## Troubleshooting

**Port already in use?**
```bash
lsof -i :8001   # Find what's using port 8001
kill -9 <PID>   # Kill the process
```

**Database won't connect?**
```bash
docker-compose logs postgres    # Check postgres logs
docker-compose restart postgres # Restart database
```

**Fresh start?**
```bash
docker-compose down -v          # Remove everything
docker-compose up -d            # Start fresh
```

---

## Next Steps

1. ✅ Run the setup script or `docker-compose up -d`
2. ✅ Visit http://localhost:8001/docs and http://localhost:8002/docs
3. ✅ Try the API endpoints
4. ✅ Add database models and update the apps
5. ✅ Write tests in `tests/` directories

---

## Documentation

- **Local Development Guide**: See `LOCAL_DEVELOPMENT.md` for detailed instructions
- **Database Schema**: See `infra/init-db.sql`
- **Docker Compose Config**: See `infra/docker-compose.yml`
- **Environment Variables**: See `.env.example` in each site directory

Happy coding! 🎉
