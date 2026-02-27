# IMIC Insurance System - Complete Database Design

## Overview

This is a production-ready T-SQL database schema for the **Indian Medical Insurance Corporation (IMIC)** system deployed on **Azure SQL Database**. It includes:

- ✅ Normalized relational schema (3NF)
- ✅ Complete entity relationships (ERD)
- ✅ Security & authentication tables
- ✅ Policy application workflow
- ✅ Claims management workflow
- ✅ Stored procedures for core operations
- ✅ Views for reporting & dashboards
- ✅ Comprehensive indexes
- ✅ Constraints & data integrity

---

## ER Model - Key Entities & Relationships

### 1. **Parties** (Actors in the system)
- `PolicyHolder` - End customer
- `Agent` - Sales/support agent
- `CompanyStaff` - IMIC employees

### 2. **Security & Access**
- `UserAccount` - Login credentials with role-based access control (RBAC)
  - Links to exactly one party based on role
  - Lockout mechanism (failed login attempts)
  - Audit trail (last login)

### 3. **Onboarding Phase**
- `PolicyApplication` - Customer application for insurance
- `ApplicationDocument` - Supporting documents (age proof, medical report, etc.)

### 4. **Active Policies**
- `Policy` - Issued insurance policy
- `Member` - Policy members (primary holder + dependents)
- `MemberDocument` - Member-specific documents

### 5. **Claims Processing**
- `Claim` - Claim submission & tracking
- `ClaimDocument` - Claim supporting documents
- `Cheque` - Payment record (1:1 with approved claim)

---

## Database Files

### 1. `infra/imic-schema.sql`
Complete DDL for all tables, indexes, and views.

**Includes:**
- Schema creation
- All 12 tables with constraints
- Covering indexes for performance
- Dashboard view for policy holders
- Sample reporting indexes

### 2. `infra/imic-workflows.sql`
Stored procedures for all business workflows.

**Includes:**
- Policy application submission (with docs)
- Application approval → policy issuance
- Claim submission (with docs)
- Claim acceptance → cheque issuance
- Claim rejection
- Login attempt handling
- Utility views for dashboards & reporting

---

## Key Features

### ✅ Data Integrity
- Foreign key constraints with cascade delete
- Check constraints for valid status values
- Unique constraints for business rules
- Primary key on all tables

### ✅ Security
- Role-based access control (POLICY_HOLDER, AGENT, STAFF)
- Role binding validation (prevents role confusion)
- Account lockout after 3 failed login attempts
- Audit trail (LastLoginAt, timestamps)

### ✅ Performance
- Strategic indexes on:
  - Search columns (Email, Phone, LicenseNo)
  - Status columns (for filtering)
  - Date columns (for date range queries)
  - Foreign keys (for joins)
  - Unique constraint (primary member per policy)

### ✅ Business Rules
- Only one primary member per policy
- Single cheque per accepted claim
- Prevents duplicate policy issuance from same application
- Cascading deletes maintain referential integrity

### ✅ Workflow Support
- Status enumerations prevent invalid states
- Timestamps for audit trail
- Transaction support for multi-step operations
- Error handling with custom error codes

---

## Data Model Structure

```
┌─────────────────────────────────────────────────────────────┐
│                     PARTIES & SECURITY                      │
├─────────────────────────────────────────────────────────────┤
│ PolicyHolder ──┐                                            │
│ Agent        ──┤──→ UserAccount (RBAC with lockout)        │
│ CompanyStaff ──┘                                            │
└─────────────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────────────┐
│                 ONBOARDING (Application)                    │
├─────────────────────────────────────────────────────────────┤
│ PolicyApplication ──→ ApplicationDocument                   │
│  (Status: Submitted/Approved/Rejected)                      │
└─────────────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────────────┐
│                  ACTIVE POLICIES                            │
├─────────────────────────────────────────────────────────────┤
│ Policy ──→ Member ──→ MemberDocument                        │
│ (1:1 with Application, 1:N with Members)                    │
└─────────────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────────────┐
│                  CLAIMS PROCESSING                          │
├─────────────────────────────────────────────────────────────┤
│ Claim ──→ ClaimDocument                                     │
│  ↓                                                           │
│ Cheque (1:1 with Accepted Claim)                            │
│ (Status: SentForApproval/Accepted/Rejected)                 │
└─────────────────────────────────────────────────────────────┘
```

---

## Core Workflows

### 1. Policy Application Submission

**Procedure:** `sp_SubmitPolicyApplication`

```sql
EXEC imic.sp_SubmitPolicyApplication
    @AgentID = 1,
    @PolicyHolderID = 10,
    @IntendedCoverAmount = 500000.00,
    @IntendedPlan = 'Premium',
    @PremiumQuote = 2500.00,
    @PaymentMode = 'Cheque',
    @ChequeNo = 'CHQ123456',
    @ChequeStatus = 'Received',
    @AgeProofPath = '/docs/age_proof.pdf',
    @MedicalReportPath = '/docs/medical_report.pdf';
```

**Workflow:**
1. Create policy application with status = "Submitted"
2. Attach age proof and medical report documents
3. Return ApplicationID

---

### 2. Approve Application & Issue Policy

**Procedure:** `sp_ApproveApplicationAndIssuePolicy`

```sql
EXEC imic.sp_ApproveApplicationAndIssuePolicy
    @ApplicationID = 100;
```

**Workflow (Transactional):**
1. Validate application exists and is submitted
2. Update application status to "Approved"
3. Create policy from application details
4. Create primary member (policy holder)
5. Commit transaction
6. Return PolicyID

---

### 3. Submit Claim

**Procedure:** `sp_SubmitClaim`

```sql
EXEC imic.sp_SubmitClaim
    @PolicyID = 200,
    @MemberID = 300,
    @AgentID = 1,
    @ClaimedAmount = 50000.00,
    @HospitalBillPath = '/docs/bill.pdf',
    @ReportPath = '/docs/diagnostic.pdf';
```

**Workflow:**
1. Create claim with status = "SentForApproval"
2. Attach hospital bill and diagnostic report
3. Return ClaimID

---

### 4. Accept Claim & Issue Cheque

**Procedure:** `sp_AcceptClaimAndIssueCheque`

```sql
EXEC imic.sp_AcceptClaimAndIssueCheque
    @ClaimID = 500,
    @ApprovedAmount = 45000.00,
    @ChequeNumber = 'CHQ987654',
    @BankName = 'ICICI Bank';
```

**Workflow (Transactional):**
1. Validate claim exists and is pending
2. Update claim status to "Accepted"
3. Record approved amount
4. Create cheque record
5. Commit transaction
6. Return success message

---

### 5. Reject Claim

**Procedure:** `sp_RejectClaim`

```sql
EXEC imic.sp_RejectClaim
    @ClaimID = 500,
    @Reason = 'Bill amount exceeds policy limit';
```

**Workflow:**
1. Update claim status to "Rejected"
2. Record rejection reason
3. Clear approved amount

---

## Authentication & Security

### Login Attempt Handling

**On Failed Login:**
```sql
EXEC imic.sp_HandleFailedLogin @Username = 'user@example.com';
```
- Increment FailedAttemptCount
- Lock account after 3 failed attempts

**On Successful Login:**
```sql
EXEC imic.sp_HandleSuccessfulLogin @UserID = 1;
```
- Reset FailedAttemptCount to 0
- Update LastLoginAt timestamp

**Admin Unlock:**
```sql
EXEC imic.sp_UnlockUserAccount @UserID = 1;
```
- Unlock account
- Reset failed attempt count

---

## Reporting Views

### 1. Policy Holder Dashboard
**View:** `vwPolicyHolderDashboard`

Shows all policies, members, and claims for a policy holder:
```sql
SELECT * FROM imic.vwPolicyHolderDashboard 
WHERE PolicyHolderID = 10;
```

### 2. Policy Holder Summary
**View:** `vwPolicyHolderSummary`

Aggregated view with policy count and claim amounts:
```sql
SELECT * FROM imic.vwPolicyHolderSummary;
```

### 3. Agent Performance
**View:** `vwAgentPerformance`

Agent KPIs: applications, policies, premium, claims:
```sql
SELECT * FROM imic.vwAgentPerformance;
```

### 4. Pending Claims
**View:** `vwPendingClaims`

All claims awaiting approval with days pending:
```sql
SELECT * FROM imic.vwPendingClaims 
ORDER BY DaysAwaitingApproval DESC;
```

---

## Database Design Principles

### Normalization
- **3NF** - All non-key attributes dependent on primary key
- **BCNF** - No anomalies from functional dependencies
- No data duplication, minimal storage

### Constraints
- **PK:** Auto-incrementing BIGINT (9.2 quintillion values)
- **FK:** Referential integrity with cascading deletes
- **CHECK:** Enum validation (Status, Role)
- **UNIQUE:** Business rules (username, primary member per policy)

### Indexes
- **Clustered:** Primary key on all tables
- **Non-Clustered:** Search, filter, and join columns
- **Filtered Unique:** Primary member constraint
- Strategy: Balance query performance with insert/update cost

### Cascading Deletes
- Deleting policy cascades to members and documents
- Deleting claim cascades to documents and cheque
- Preserves referential integrity

---

## Performance Considerations

### Query Optimization
- All foreign keys indexed
- Status columns indexed for WHERE clauses
- Date columns indexed for time-based queries
- Email/Phone indexed for search

### Scalability
- BIGINT identity (handles billions of records)
- Partitioning ready (by date or policy holder)
- View-based reporting (no ETL needed)
- Stored procedures for complex operations

### Monitoring
- Timestamps on all records (audit trail)
- Login tracking (LastLoginAt)
- Document upload tracking
- Decision timestamps on claims

---

## Integration with FastAPI

The database is ready for integration with your FastAPI applications:

```python
# Connection string for Azure SQL
DATABASE_URL = "mssql+pyodbc://user:password@server.database.windows.net:1433/imic_db?driver=ODBC+Driver+17+for+SQL+Server"

# Or with environment variable
DATABASE_URL = os.getenv("DATABASE_URL")

# SQLAlchemy ORM mapping
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
```

---

## Deployment Steps

### 1. Create Database on Azure
```bash
az sql db create \
  --resource-group <rg> \
  --server <server> \
  --name imic_db
```

### 2. Run DDL Script
```bash
sqlcmd -S <server>.database.windows.net \
       -U <username> \
       -P <password> \
       -d imic_db \
       -i infra/imic-schema.sql
```

### 3. Run Workflow Procedures
```bash
sqlcmd -S <server>.database.windows.net \
       -U <username> \
       -P <password> \
       -d imic_db \
       -i infra/imic-workflows.sql
```

### 4. Set Connection String in App
Update FastAPI `.env`:
```env
DATABASE_URL=mssql+pyodbc://user:pass@server.database.windows.net:1433/imic_db?driver=ODBC+Driver+17+for+SQL+Server
```

---

## Testing

### Test Data Insertion
```sql
-- Insert policy holder
INSERT INTO imic.PolicyHolder (FullName, DOB, Email, Phone, Address)
VALUES ('Rajesh Kumar', '1980-05-15', 'rajesh@example.com', '9876543210', '123 Main St');

-- Insert agent
INSERT INTO imic.Agent (Name, LicenseNo, Email, Phone, Branch)
VALUES ('Amit Singh', 'LIC123456', 'amit@example.com', '9876543211', 'Mumbai');

-- Insert user account
INSERT INTO imic.UserAccount (Username, PasswordHash, Role, PolicyHolderID)
VALUES ('rajesh@example.com', 0x..., N'POLICY_HOLDER', 1);
```

### Test Workflow
```sql
-- Submit application
EXEC imic.sp_SubmitPolicyApplication ...

-- Approve application
EXEC imic.sp_ApproveApplicationAndIssuePolicy ...

-- Submit claim
EXEC imic.sp_SubmitClaim ...

-- Accept claim
EXEC imic.sp_AcceptClaimAndIssueCheque ...
```

---

## Error Codes

| Code | Message | Meaning |
|------|---------|---------|
| 50001 | Application not approvable | Already processed or wrong status |
| 50002 | Claim not approvable | Already processed or wrong status |
| 50003 | Claim not found | Claim doesn't exist |

---

## Next Steps

1. ✅ Review schema in `imic-schema.sql`
2. ✅ Review workflows in `imic-workflows.sql`
3. ✅ Deploy to Azure SQL Database
4. ✅ Test stored procedures
5. ✅ Create ORM models in FastAPI
6. ✅ Build API endpoints around workflows
7. ✅ Set up monitoring & alerts

---

## Files Included

- `imic-schema.sql` - Complete DDL with tables, indexes, constraints
- `imic-workflows.sql` - Stored procedures & reporting views
- `IMIC_DATABASE_DESIGN.md` - This documentation

Ready for production deployment! 🚀
