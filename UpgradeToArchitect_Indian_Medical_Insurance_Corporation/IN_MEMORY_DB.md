# In-Memory Database Setup

## Overview

Use SQLite in-memory database for super-fast development and testing without any persistence.

**Perfect for:**
- ✅ Testing code changes instantly
- ✅ No database setup needed
- ✅ Lightweight (no Docker services)
- ✅ Fresh state every restart
- ✅ Learning and prototyping

**Not ideal for:**
- ❌ Persisting data between runs
- ❌ Multi-process applications
- ❌ Production use

---

## Quick Start

### Option 1: Docker with In-Memory SQLite (Recommended)

```bash
cd infra
docker-compose -f docker-compose.inmemory.yml up -d
```

Services will start:
- Intranet: http://localhost:8001
- Internet: http://localhost:8002
- No database UI needed

Stop with:
```bash
docker-compose -f docker-compose.inmemory.yml down
```

### Option 2: Pure Python (No Docker)

```bash
# Terminal 1 - Intranet
cd intranet-site
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
DATABASE_URL=sqlite:///:memory: python -m uvicorn app.main:app --reload --port 8001

# Terminal 2 - Internet
cd internet-site
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
DATABASE_URL=sqlite:///:memory: python -m uvicorn app.main:app --reload --port 8002
```

---

## Configuration

### Environment Variables

```bash
# Use in-memory SQLite
DATABASE_URL=sqlite:///:memory:
DB_TYPE=sqlite
IN_MEMORY=true

# Or use file-based SQLite (persists to disk)
DATABASE_URL=sqlite:///./medical_insurance.db
DB_TYPE=sqlite
IN_MEMORY=false
```

### Docker Compose

Use the in-memory compose file:
```bash
# In-memory (fast, no persistence)
docker-compose -f docker-compose.inmemory.yml up -d

# PostgreSQL (persistent)
docker-compose up -d

# Hybrid (both services with in-memory, no database container)
docker-compose -f docker-compose.inmemory.yml up -d
```

---

## How It Works

### SQLite In-Memory (`:memory:`)

```python
# Database exists only in RAM
DATABASE_URL = "sqlite:///:memory:"

# Fresh state on every startup
# All data lost on restart
# No file I/O overhead
# Single connection at a time
```

### SQLite File-Based

```python
# Database persists to file
DATABASE_URL = "sqlite:///./medical_insurance.db"

# Data persists between restarts
# Can use multiple connections
# Slower than in-memory
```

### PostgreSQL (Full Version)

```python
# Persistent network database
DATABASE_URL = "postgresql://user:pass@localhost:5432/db"

# Full ACID compliance
# Multiple concurrent connections
# Shared between services
# Best for production
```

---

## Comparison

| Feature | In-Memory | SQLite File | PostgreSQL |
|---------|-----------|-------------|------------|
| Speed | ⚡⚡⚡ Fast | ⚡⚡ Medium | ⚡ Slower |
| Persistence | ❌ No | ✅ Yes | ✅ Yes |
| Setup | ✅ None | ✅ Easy | ⚠️ Complex |
| Data Loss | ⚠️ On Restart | ✅ Never | ✅ Never |
| Concurrency | ❌ Limited | ⚠️ Single | ✅ Full |
| Production | ❌ No | ❌ No | ✅ Yes |
| Testing | ✅ Perfect | ✅ Good | ⚠️ Overkill |

---

## Use Cases

### 1. Fast Development Testing

```bash
# Start with in-memory for quick iterations
docker-compose -f docker-compose.inmemory.yml up -d

# Edit code
vim internet-site/app/main.py

# Auto-reload happens instantly
# No database overhead
# Fresh state for each test
```

### 2. Automated Testing

```bash
# Run tests with in-memory database
export DATABASE_URL=sqlite:///:memory:
pytest tests/ -v

# Fast test execution
# No shared state between tests
# No cleanup needed
```

### 3. CI/CD Pipeline

```yaml
# GitHub Actions example
env:
  DATABASE_URL: sqlite:///:memory:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: pytest tests/ -v
```

### 4. Demo/Prototype

```bash
# Show features without setup
docker-compose -f docker-compose.inmemory.yml up -d

# Open http://localhost:8001/docs
# Show API in Swagger UI
# No persistent state to worry about
```

---

## SQLAlchemy Configuration

### In-Memory SQLite

```python
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# In-memory database
engine = create_engine(
    "sqlite:///:memory:",
    connect_args={"check_same_thread": False},  # Allow concurrent access
    echo=False  # Set to True to see SQL queries
)

SessionLocal = sessionmaker(bind=engine)
```

### File-Based SQLite

```python
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# File-based database
engine = create_engine(
    "sqlite:///./medical_insurance.db",
    connect_args={"check_same_thread": False},
    echo=False
)

SessionLocal = sessionmaker(bind=engine)
```

### PostgreSQL

```python
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# PostgreSQL database
engine = create_engine(
    "postgresql://medical_user:medical_password@localhost:5432/medical_insurance",
    echo=False,
    pool_size=10,
    max_overflow=20
)

SessionLocal = sessionmaker(bind=engine)
```

---

## Common Commands

### Start In-Memory Services

```bash
cd infra
docker-compose -f docker-compose.inmemory.yml up -d
```

### View Logs

```bash
# All services
docker-compose -f docker-compose.inmemory.yml logs -f

# Specific service
docker-compose -f docker-compose.inmemory.yml logs -f intranet-site
```

### Restart Services

```bash
docker-compose -f docker-compose.inmemory.yml restart
```

### Stop Services

```bash
docker-compose -f docker-compose.inmemory.yml down
```

### Switch to PostgreSQL

```bash
# Stop in-memory
docker-compose -f docker-compose.inmemory.yml down

# Start PostgreSQL version
docker-compose up -d
```

---

## Troubleshooting

### "Database locked" error

In-memory SQLite is limited to one connection. Use PostgreSQL if you need:
- Multiple concurrent connections
- Multi-threaded applications
- Multiple processes

### Data disappears after restart

That's expected! In-memory databases only exist during the session.

Use file-based SQLite to persist:
```bash
DATABASE_URL=sqlite:///./medical_insurance.db
```

### Want to inspect the database?

In-memory databases are in RAM, but you can:

1. Add debug logging:
```python
engine = create_engine("sqlite:///:memory:", echo=True)
```

2. Export to file for inspection:
```python
import shutil
shutil.copy(":memory:", "debug.db")
```

3. Use PostgreSQL instead for visual tools.

---

## Performance

### In-Memory SQLite Benchmarks

- **Connection time**: < 1ms
- **Insert**: 0.1ms per record
- **Query**: < 0.5ms
- **Memory**: ~5MB per database

### When to Use Each

**In-Memory** → Development & Testing
- Fastest for local work
- No setup required
- Fresh state each run

**SQLite File** → Light Projects
- Still fast
- Persists data
- Good for small apps

**PostgreSQL** → Production & Complex Apps
- Multiple concurrent users
- Advanced features
- Scaling capability

---

## Example: Test with In-Memory DB

```python
# tests/test_api.py
import os
os.environ["DATABASE_URL"] = "sqlite:///:memory:"

from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

def test_create_policy():
    response = client.post("/api/v1/policies", json={
        "policy_number": "POL-001",
        "customer_id": "user-123",
        "policy_type": "individual",
        "effective_date": "2026-02-26"
    })
    assert response.status_code == 201
```

---

## Next Steps

1. **Try in-memory DB:**
   ```bash
   docker-compose -f docker-compose.inmemory.yml up -d
   ```

2. **Visit the APIs:**
   - http://localhost:8001/docs
   - http://localhost:8002/docs

3. **Make changes and test:**
   - Edit code
   - Reload happens instantly
   - No database state to worry about

4. **When you need persistence:**
   ```bash
   docker-compose up -d  # Switch to PostgreSQL
   ```

---

## Summary

- **In-Memory DB**: Perfect for fast development & testing
- **No setup**: Just set `DATABASE_URL=sqlite:///:memory:`
- **Use compose file**: `docker-compose.inmemory.yml`
- **Switch anytime**: Change one env variable or compose file
- **Both available**: In-memory for dev, PostgreSQL for persistence

Happy coding! 🚀
