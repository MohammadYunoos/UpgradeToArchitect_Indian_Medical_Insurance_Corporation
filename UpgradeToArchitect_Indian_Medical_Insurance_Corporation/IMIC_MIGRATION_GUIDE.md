# IMIC System - Database Migration Guide

## Overview

You now have **three database options**:

1. **SQLite In-Memory** - Fast development & testing
2. **PostgreSQL** - Persistent local development
3. **Azure SQL Database** - Production with IMIC schema

This guide explains how to switch between them.

---

## Database Options Comparison

| Feature | In-Memory SQLite | PostgreSQL | Azure SQL |
|---------|-----------------|------------|-----------|
| **Startup** | 2-5 sec | 10-15 sec | Always ready |
| **Persistence** | ❌ No | ✅ Yes | ✅ Yes |
| **Production** | ❌ No | ❌ No | ✅ Yes |
| **Cost** | Free | Free | Paid |
| **Setup** | None | Docker | Azure |
| **Use For** | Testing | Development | Production |

---

## Architecture Layers

```
┌────────────────────────────────────────────┐
│       FastAPI Application                   │
│  (intranet-site, internet-site)             │
└────────────────────────────────────────────┘
              ↓ SQLAlchemy ORM
┌────────────────────────────────────────────┐
│       Database Abstraction Layer             │
└────────────────────────────────────────────┘
              ↓ Connection String
┌─────────────────────────────────────────────────────────────────┐
│                   Database Engines                               │
├─────────────────────────────────────────────────────────────────┤
│ sqlite:///:memory:              (In-Memory)                    │
│ sqlite:///./app.db              (SQLite File)                  │
│ postgresql://user:pass@...      (PostgreSQL)                   │
│ mssql+pyodbc://user:pass@...    (Azure SQL)                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Local Development (SQLite/PostgreSQL)

### Using In-Memory SQLite
```bash
# Start
make up-memory

# Environment
DATABASE_URL=sqlite:///:memory:
```

**Best for:**
- Unit tests
- Feature development
- Quick iterations
- CI/CD pipelines

### Using PostgreSQL
```bash
# Start
make up

# Environment
DATABASE_URL=postgresql://medical_user:medical_password@localhost:5432/medical_insurance
```

**Best for:**
- Integration testing
- Multi-connection testing
- Production simulation
- Real feature development

---

## Production Deployment (Azure SQL)

### Prerequisites

1. **Azure Account** with SQL Database
2. **Connection String** from Azure Portal
3. **IMIC Schema** deployed

### Step 1: Create Azure SQL Database

```bash
# Create resource group
az group create \
  --name imic-rg \
  --location eastus

# Create SQL server
az sql server create \
  --resource-group imic-rg \
  --name imic-server-$(date +%s) \
  --admin-user sqladmin \
  --admin-password <SecurePassword>

# Create database
az sql db create \
  --resource-group imic-rg \
  --server <server-name> \
  --name imic_production \
  --sku Standard
```

### Step 2: Deploy IMIC Schema

```bash
# Download SQL Client (sqlcmd)
# macOS: brew install mssql-tools18

# Run schema script
sqlcmd -S <server>.database.windows.net \
       -U sqladmin \
       -P <SecurePassword> \
       -d imic_production \
       -i infra/imic-schema.sql

# Run workflow procedures
sqlcmd -S <server>.database.windows.net \
       -U sqladmin \
       -P <SecurePassword> \
       -d imic_production \
       -i infra/imic-workflows.sql
```

### Step 3: Configure Firewall

```bash
# Add your IP to firewall
az sql server firewall-rule create \
  --resource-group imic-rg \
  --server <server-name> \
  --name AllowMyIP \
  --start-ip-address <your-ip> \
  --end-ip-address <your-ip>

# Or allow Azure services
az sql server firewall-rule create \
  --resource-group imic-rg \
  --server <server-name> \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

### Step 4: Get Connection String

```bash
# From Azure Portal: SQL Database → Connection Strings
# Format: mssql+pyodbc://user:pass@server.database.windows.net:1433/database?driver=ODBC+Driver+17+for+SQL+Server

# Or via CLI
az sql db show-connection-string \
  --client pyodbc \
  --auth-type SqlPassword
```

### Step 5: Update Application

**Update `.env`:**
```env
DATABASE_URL=mssql+pyodbc://sqladmin:YourPassword@imic-server.database.windows.net:1433/imic_production?driver=ODBC+Driver+17+for+SQL+Server
```

**Or use Azure Key Vault:**
```python
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

credential = DefaultAzureCredential()
client = SecretClient(vault_url=kv_url, credential=credential)
db_url = client.get_secret("database-connection-string").value
```

---

## Connection Strings

### SQLite (In-Memory)
```python
DATABASE_URL = "sqlite:///:memory:"
```

### SQLite (File-Based)
```python
DATABASE_URL = "sqlite:///./insurance_app.db"
```

### PostgreSQL (Local)
```python
DATABASE_URL = "postgresql://user:password@localhost:5432/imic_db"
```

### Azure SQL (Production)
```python
DATABASE_URL = "mssql+pyodbc://username:password@server.database.windows.net:1433/imic_production?driver=ODBC+Driver+17+for+SQL+Server"
```

---

## FastAPI Configuration

### Dynamic Database Selection

```python
# config.py
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

db_url = os.getenv("DATABASE_URL")

# Auto-detect and configure based on URL
if "sqlite" in db_url:
    engine = create_engine(
        db_url,
        connect_args={"check_same_thread": False}
    )
elif "postgresql" in db_url:
    engine = create_engine(
        db_url,
        pool_size=10,
        max_overflow=20
    )
elif "mssql" in db_url:
    engine = create_engine(
        db_url,
        pool_size=10,
        max_overflow=20,
        pool_pre_ping=True
    )

SessionLocal = sessionmaker(bind=engine)
```

---

## Migration Path

### Phase 1: Development (SQLite/PostgreSQL)
```bash
# Use in-memory for fast testing
make up-memory
export DATABASE_URL=sqlite:///:memory:
pytest tests/

# Use PostgreSQL for real development
make up
export DATABASE_URL=postgresql://...
python -m uvicorn app.main:app --reload
```

### Phase 2: Testing (All Three)
```bash
# Test with each database
export DATABASE_URL=sqlite:///:memory:
pytest tests/  # Fast

export DATABASE_URL=postgresql://...
pytest tests/  # Real database

export DATABASE_URL=mssql+pyodbc://...
pytest tests/  # Production database
```

### Phase 3: Staging (Azure SQL)
```bash
# Deploy to staging with real Azure SQL
export DATABASE_URL=mssql+pyodbc://user:pass@staging-server.database.windows.net/imic_staging
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### Phase 4: Production (Azure SQL)
```bash
# Deploy to production with Azure SQL
export DATABASE_URL=mssql+pyodbc://user:pass@prod-server.database.windows.net/imic_production
# Use Azure Key Vault for secrets
# Set up monitoring & backups
```

---

## Switching Databases

### Local: SQLite → PostgreSQL
```bash
# Stop SQLite
make down-memory

# Start PostgreSQL
make up

# Update code
export DATABASE_URL=postgresql://...
```

### Local: PostgreSQL → Azure SQL
```bash
# Keep PostgreSQL running for reference

# Deploy schema to Azure
sqlcmd -S <server>.database.windows.net ... -i imic-schema.sql

# Update connection string
export DATABASE_URL=mssql+pyodbc://...

# Test with real data
pytest tests/
```

### Cloud: Staging → Production
```bash
# Backup production database first
# (handled by Azure automatically)

# Update connection string
export DATABASE_URL=mssql+pyodbc://user:pass@prod-server.database.windows.net/imic_production

# Deploy application
# (via Azure App Service, Kubernetes, etc.)
```

---

## Data Management

### Backup & Recovery

**PostgreSQL (Local):**
```bash
# Backup
pg_dump -U user -h localhost imic_db > backup.sql

# Restore
psql -U user -h localhost imic_db < backup.sql
```

**Azure SQL:**
```bash
# Automatic backups (35 days retention)
# Manual backup
az sql db backup create \
  --resource-group imic-rg \
  --server <server> \
  --name imic_production

# Restore from backup
az sql db restore \
  --resource-group imic-rg \
  --server <server> \
  --name imic_production_restored \
  --backup-resource-name imic_production \
  --backup-resource-group imic-rg \
  --backup-resource-type Microsoft.Sql/servers/databases
```

### Data Migration

**PostgreSQL → Azure SQL:**

```bash
# Export from PostgreSQL
pg_dump -h localhost -U user imic_db --no-password > export.sql

# Convert T-SQL dialect as needed
# (Most standard SQL is compatible)

# Import to Azure SQL
sqlcmd -S server.database.windows.net -U user -P pass -d imic_production -i export.sql
```

---

## Troubleshooting

### Connection Issues

**SQLite:**
```python
# Check file exists
import os
if os.path.exists("./insurance_app.db"):
    print("Database file found")
```

**PostgreSQL:**
```bash
# Test connection
psql -h localhost -U user -d imic_db -c "SELECT 1"
```

**Azure SQL:**
```bash
# Test connection
sqlcmd -S server.database.windows.net -U user -P pass -Q "SELECT 1"

# Check firewall rules
az sql server firewall-rule list \
  --resource-group imic-rg \
  --server <server>
```

### Performance Issues

**Add indexes (all databases):**
```sql
CREATE INDEX idx_policy_holder ON imic.Policy(PolicyHolderID);
CREATE INDEX idx_claim_status ON imic.Claim(Status);
```

**Monitor Azure SQL:**
```bash
az sql server-audit-setting show \
  --resource-group imic-rg \
  --server <server>

az sql db show-metrics \
  --resource-group imic-rg \
  --server <server> \
  --name imic_production
```

---

## Recommended Workflow

### For Developers
1. **Local development:** `make up-memory` (SQLite in-memory)
2. **Testing:** Switch to `make up` (PostgreSQL) for integration tests
3. **Before commit:** Run tests on both databases
4. **Before deployment:** Test against staging Azure SQL

### For DevOps
1. **Staging:** Deploy to Azure SQL staging environment
2. **Testing:** Run full test suite against staging
3. **Backup:** Verify backup strategy works
4. **Production:** Deploy to Azure SQL production
5. **Monitor:** Set up alerts & monitoring

### For QA
1. **Test data:** Use production-like Azure SQL
2. **Performance:** Test against real production database
3. **Scalability:** Verify indexes & query plans
4. **Compliance:** Verify audit trails & logging

---

## Cost Optimization (Azure SQL)

```bash
# Start with Basic tier
az sql db update \
  --resource-group imic-rg \
  --server <server> \
  --name imic_production \
  --edition Basic \
  --service-objective B

# Scale up if needed
az sql db update \
  --resource-group imic-rg \
  --server <server> \
  --name imic_production \
  --edition Standard \
  --service-objective S1

# Pause when not in use (DevTest tier)
az sql db pause \
  --resource-group imic-rg \
  --server <server> \
  --name imic_production
```

---

## Next Steps

1. ✅ **Local Development:** Start with `make up-memory`
2. ✅ **Testing:** Add tests with `make up` (PostgreSQL)
3. ✅ **Staging:** Deploy IMIC schema to Azure SQL staging
4. ✅ **Production:** Configure Azure SQL production database
5. ✅ **Monitoring:** Set up alerts & backups

---

## Files Reference

| File | Purpose |
|------|---------|
| `imic-schema.sql` | Database DDL (all tables, indexes, constraints) |
| `imic-workflows.sql` | Stored procedures & views |
| `IMIC_DATABASE_DESIGN.md` | Complete database documentation |
| `.env.example` | Environment variable template |

---

## Support

- **Local Issues:** See `LOCAL_DEVELOPMENT.md`
- **Database Design:** See `IMIC_DATABASE_DESIGN.md`
- **Azure Setup:** See Azure SQL documentation
- **Migration:** Contact DevOps team

Ready to scale! 🚀
