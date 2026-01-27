# Security Requirements Document (SRD)
## Indian Medical Insurance Corporation (IMIC)
### Prepared by: Senior Security Architect & Compliance Officer (Indian BFSI Sector)

## 1. Introduction
### 1.1 Objective
This Security Requirements Document (SRD) establishes mandatory security controls for designing, developing, deploying, and operating IMIC’s hybrid medical insurance system. The document provides actionable, testable requirements for Software Engineer Trainees to build systems that safeguard PII, ePHI, and financial data in compliance with the DPDP Act (India) and healthcare‑grade standards similar to HIPAA.

### 1.2 Scope
The SRD applies to:
- Customer Web Portal (Policy Holders)
- Insurance Agent Web Portal
- Internal Staff Intranet (Claims, Underwriting, Operations)
- Backend APIs, Databases, Logging Systems
- Both deployment models: Cloud (AWS/Azure – India region) and On‑Premise

## 2. User Authentication & Authorization
### 2.1 Authentication Requirements
| Requirement | Description | Testable Criteria |
|------------|-------------|------------------|
| MFA | Agents & Staff must authenticate using MFA (TOTP/Push Notification). Policyholders: Optional but recommended. | MFA challenge triggered on every login. |
| Password Policy | Minimum 12 characters, 1 uppercase, 1 lowercase, 1 digit, 1 special character. | Weak passwords are rejected. |
| Session Timeout | Auto‑logout after 15 minutes inactivity, absolute max lifespan 8 hours. | Idle session terminates at 15 mins. |
| Device Binding (Staff Only) | Login allowed only from registered corporate devices. | Unregistered device results in access denied. |

### 2.2 Account Lockdown Policy
**Rule: 3 Consecutive Invalid Attempts**
- On 3 failed login attempts, the account enters **Locked** state.
- Lockout duration: **30 minutes** (automatic unlock).
- Manual unlock requires:
  - Verification by IMIC support
  - Logged administrative action

**Workflow:**
1. System logs failed attempts.
2. On attempt #3 → Lock account.
3. User receives email/SMS notification.
4. Support Staff → Admin Portal → “Reactivate Account”.
5. System logs unlock event.

### 2.3 Role‑Based Access Control (RBAC)
| Module / Action | Policy Holder | Agent | Staff |
|-----------------|---------------|--------|--------|
| View Policy | Read‑Only | Read | Read/Write |
| File Claims | Yes | Yes (on behalf) | Full Control |
| Approve/Reject Claims | No | No | Yes |
| Update Customer Details | No | Limited | Yes |
| Access Reports | No | No | Yes (role‑based segmentation) |
| Admin Functions | No | No | Yes (Admin Role Only) |

Principles Applied:
- Least Privilege
- Segregation of Duties
- Zero Trust — Verify every access request

## 3. Data Security Requirements
### 3.1 Data Encryption
| Data Type | Requirement |
|-----------|-------------|
| Data at Rest | AES‑256 (Cloud KMS or On‑Prem HSM) |
| Data in Transit | TLS 1.3 with Perfect Forward Secrecy |
| Backups | Encrypted using AES‑256‑GCM |

### 3.2 Data Masking / Minimization
- Show only masked Aadhaar/PAN to Agents.
- Policy holders can only see their own data (read‑only).
- Staff access enforced using Attribute‑Based Access (ABAC) for ePHI.

### 3.3 Sensitive Data Storage Rules
- Aadhaar must follow UIDAI Virtual ID (VID) usage.
- ePHI must NEVER be logged.
- Encryption keys rotated every 90 days.

## 4. Infrastructure Security – Dual‑Path Strategy

# 4A. Cloud Deployment Scenario (AWS/Azure – India Region)
### 4A.1 Identity & Access Management
- IAM roles **NOT** IAM users for application access.
- Principle of Least Privilege for EC2/VM, RDS/Azure SQL, Lambda/Functions.
- Admin actions require MFA + Just‑In‑Time (JIT) access.

### 4A.2 Networking
- Application in **private subnets**.
- Public‑facing API protected by:
  - API Gateway throttling
  - WAF rules (OWASP Core Rule Set)
- DDoS Protection: AWS Shield / Azure DDoS Standard.

### 4A.3 Database Security
- Managed SQL (RDS/Azure SQL) with:
  - TDE (AES‑256)
  - Automated backups (encrypted)
  - Network-level blocking of public access
- Rotate DB credentials via Secrets Manager/Key Vault.

### 4A.4 Logging & Monitoring
- CloudTrail / Azure Activity Logs enabled.
- Log retention: **7 years** (IRDAI requirement alignment).
- SIEM integration (Microsoft Sentinel/Splunk).

### 4A.5 Shared Responsibility Clarification
| Area | IMIC Responsibility | Cloud Provider |
|------|---------------------|----------------|
| App Code | ✔️ | |
| IAM Policies | ✔️ | |
| Patching OS (IaaS) | ✔️ | |
| Physical Security | | ✔️ |
| Network Backbone Security | | ✔️ |

# 4B. On‑Premise Deployment Scenario
### 4B.1 Network Design (DMZ Approach)
- Public Web Servers placed in **DMZ subnet**.
- Internal App Servers and Databases in **restricted VLANs**.
- Mandatory firewall segmentation between:
  - Internet ↔ DMZ
  - DMZ ↔ Application
  - Application ↔ Database

### 4B.2 Physical Security
- 24/7 surveillance
- Biometric access
- Visitor logs
- Fire suppression systems

### 4B.3 Perimeter Security
- Enterprise‑grade firewalls with IPS/IDS.
- SSL decryption for outbound traffic monitoring.
- VPN with MFA for remote staff.

### 4B.4 Database Security
- SQL Server/Oracle secured with:
  - Transparent Data Encryption (TDE)
  - Least‑privilege DB roles
  - Dedicated backup network

## 5. Application Security (AppSec)
### 5.1 Input Validation
- Whitelisting approach for all form fields.
- Stop list for common attack signatures.
- Server‑side validation is mandatory.

### 5.2 Secure File Uploads (Medical Reports)
- Allowed formats: PDF, JPG, PNG only.
- Max file size: 5 MB.
- Antivirus scan (ClamAV or equivalent).
- Store in object storage *not* in database.
- Filenames must be randomized (GUID).

### 5.3 OWASP Top 10 Controls
System must be protected against:
- Injection (SQL/LDAP/NoSQL)
- Broken Authentication
- Sensitive Data Exposure
- XML External Entity (XXE)
- Broken Access Control
- Security Misconfigurations
- XSS (Reflected/Stored)
- Insecure Deserialization
- Using Vulnerable Components
- Insufficient Logging

## 6. Audit & Logging Requirements
### 6.1 Mandatory Events to Log
| Event | Who | Why |
|-------|------|------|
| Login/Logout | All users | Forensic support |
| 3 Failed Login Attempts | All users | Security detection |
| Claim Submission | Policy Holder / Agent | Non‑repudiation |
| Claim Approval/Rejection | Staff | Compliance audit |
| Policy Updates | Staff | Change tracking |
| Admin Actions | Staff | High‑risk monitoring |

### 6.2 Log Retention
- Application Logs: **7 years**
- Security Logs: **7 years**
- Audit Logs: **10 years** (per IRDAI guidelines)

### 6.3 Tamper‑Proofing
- Logs must be immutable:
  - Cloud: Write‑once storage (S3 Object Lock/Azure Immutable Blobs)
  - On‑Prem: WORM storage

## 7. Compliance & Governance
### 7.1 DPDP Act (India) Requirements
- Purpose Limitation
- Consent Management
- Data Principal Rights: Access, Correction, Erasure
- Data Breach Notification: Within 72 hours

### 7.2 HIPAA‑Like ePHI Requirements
- Minimum necessary data
- Strict access control
- Audit logs
- Encryption in transit and at rest

### 7.3 IRDAI Requirements
- Data residency in India
- Retain records for 7+ years
- Annual CERT‑IN VAPT
