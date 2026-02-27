# Database Options - Quick Comparison

## Choose Your Database Strategy

### 🚀 In-Memory SQLite (Fastest)
```bash
make up-memory
```
- ⚡ Ultra-fast startup (< 5 seconds)
- 🧠 No persistent data
- 💨 Perfect for testing and development
- 🎯 Fresh state on every restart
- 📊 Single connection at a time

**Use when:** Developing, testing, prototyping

---

### 💾 PostgreSQL (Full-Featured)
```bash
make up
```
- 🔄 Persistent data across restarts
- 🎯 Multiple concurrent connections
- 🛡️ Full ACID compliance
- 🔌 PgAdmin web UI included
- 📈 Production-ready

**Use when:** Need persistent data, testing concurrent access, production prep

---

## Quick Decision Tree

```
Do you need data to persist?
│
├─ NO  → Use In-Memory SQLite (make up-memory) ⚡
│       Perfect for: Testing, development, demos
│
└─ YES → Use PostgreSQL (make up) 💾
         Perfect for: Real development, integration testing
```

---

## Commands Cheat Sheet

| Task | In-Memory | PostgreSQL |
|------|-----------|------------|
| Start | `make up-memory` | `make up` |
| Stop | `make down-memory` | `make down` |
| Logs | `make logs-memory` | `make logs` |
| View All | `make help` | `make help` |

---

## What's Different?

### In-Memory Mode
```bash
# Start
make up-memory

# Services run with SQLite in-memory database
# No PgAdmin
# Super fast
# Data lost on restart

# Stop
make down-memory
```

### PostgreSQL Mode
```bash
# Start
make up

# Services run with PostgreSQL database
# PgAdmin available at http://localhost:5050
# Data persists
# Multiple connections supported

# Stop
make down
```

---

## Performance

```
Operation              In-Memory SQLite    PostgreSQL
─────────────────────────────────────────────────────
Startup Time           2-5 seconds         10-15 seconds
Create Table           < 0.1ms             1-5ms
Insert Record          0.1ms               1-2ms
Query 1000 records     < 0.5ms             5-10ms
Memory Usage           5MB                 100MB+
Connections            Single              Multiple
Data Persistence       None                Full
```

---

## When to Switch Databases

### Start With In-Memory
```bash
make up-memory
```
Good for:
- Learning the code
- Quick prototyping
- Testing API endpoints
- Running automated tests
- CI/CD pipelines

### Switch to PostgreSQL
```bash
# Stop in-memory
make down-memory

# Start PostgreSQL
make up
```
When you need:
- Data persistence
- Multiple concurrent connections
- Testing concurrent access
- Integration testing
- Preparing for production

---

## Example: Development Workflow

### Day 1: Quick Development
```bash
# Fast setup with in-memory
make up-memory

# Open in browser
http://localhost:8001/docs
http://localhost:8002/docs

# Code and test
# Auto-reload on changes

# Done for the day
make down-memory
```

### Day 2: Real Testing
```bash
# Need persistent data now
make up

# Same URLs work
http://localhost:8001/docs
http://localhost:8002/docs

# Plus database UI
http://localhost:5050

# Data persists between sessions

# When done
make down  # Keep data
# or
make down-clean  # Remove everything
```

---

## Environment Variables

### In-Memory SQLite
```bash
DATABASE_URL=sqlite:///:memory:
DB_TYPE=sqlite
IN_MEMORY=true
```

### File-Based SQLite
```bash
DATABASE_URL=sqlite:///./medical_insurance.db
DB_TYPE=sqlite
IN_MEMORY=false
```

### PostgreSQL
```bash
DATABASE_URL=postgresql://medical_user:medical_password@localhost:5432/medical_insurance
DB_HOST=localhost
DB_PORT=5432
DB_NAME=medical_insurance
DB_USER=medical_user
DB_PASSWORD=medical_password
```

---

## Switching Between Options

### From In-Memory to PostgreSQL
```bash
# Stop in-memory
make down-memory

# Start PostgreSQL (creates fresh database)
make up

# Done! Both sites use PostgreSQL now
```

### From PostgreSQL to In-Memory
```bash
# Stop PostgreSQL (keeps data)
make down

# Start in-memory
make up-memory

# Done! Both sites use in-memory SQLite now
```

---

## Files Reference

| Database | Compose File | Make Command |
|----------|-------------|--------------|
| In-Memory SQLite | `docker-compose.inmemory.yml` | `make up-memory` |
| PostgreSQL | `docker-compose.yml` | `make up` |
| Documentation | `IN_MEMORY_DB.md` | `cat IN_MEMORY_DB.md` |

---

## Testing with Different Databases

### Run Tests with In-Memory
```bash
export DATABASE_URL=sqlite:///:memory:
pytest tests/ -v
```

### Run Tests with PostgreSQL
```bash
export DATABASE_URL=postgresql://medical_user:medical_password@localhost:5432/medical_insurance
pytest tests/ -v
```

---

## FAQs

**Q: Can I use both at the same time?**
A: No, services run on the same ports. Stop one to start the other.

**Q: Where does in-memory data go?**
A: Nowhere - it's lost when the container stops. That's the point!

**Q: How do I keep PostgreSQL data?**
A: Use `make down` (not `down-clean`) to preserve data.

**Q: Can I switch databases without losing code?**
A: Yes! Your code stays the same, only database changes.

**Q: Why is in-memory so fast?**
A: No disk I/O, no network overhead, pure RAM speed.

**Q: Is in-memory good for production?**
A: No, use PostgreSQL for production.

---

## Recommendations

### For Learning
→ Start with `make up-memory`
- Fast feedback loop
- No data persistence worries
- Simple and focused

### For Development
→ Use `make up` (PostgreSQL)
- Keep your data between sessions
- Test realistic scenarios
- Practice with production-like setup

### For Testing
→ Use `make up-memory` per-test-run
- Fresh state for each test
- Fast execution
- No cleanup needed

### For Production
→ Use PostgreSQL on cloud provider
- Full backup & recovery
- Monitoring & alerting
- High availability

---

## Next Steps

1. **Try in-memory now:**
   ```bash
   make up-memory
   ```

2. **Visit the APIs:**
   - http://localhost:8001/docs
   - http://localhost:8002/docs

3. **When ready for persistence:**
   ```bash
   make down-memory
   make up
   ```

4. **Read more:**
   - `IN_MEMORY_DB.md` - Detailed in-memory guide
   - `LOCAL_DEVELOPMENT.md` - PostgreSQL guide
   - `START_HERE.md` - Overview

Happy coding! 🚀
