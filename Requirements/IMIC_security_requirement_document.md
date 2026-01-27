# Security Requirements Architecture Document

**Project:** Enterprise Hybrid Portal (EHP)  
**Version:** 1.0  
**Status:** Final  
**Classification:** Confidential  

---

## 1. Case Study Metadata
* **Application Name:** Enterprise Hybrid Portal (EHP)
* **Brief Description:** A high-availability platform providing public-facing customer services via the Internet and sensitive administrative/operational tools via a restricted Intranet.
* **Application Type:** Multi-tier Web Application
* **Architecture Style:** N-Tier with isolated Web, Application, and Database layers.
* **Deployment Type:** Hybrid (Dual-stack Internet and Intranet sites).
* **Infrastructure:** Distributed environment utilizing Cloud Managed Services and On-Premise Virtual Machines.

---

## 2. Roles & Identity Management (IAM)

### 2.1 User Roles & Access Scope
| Role | Access Environment | Authorization Level |
| :--- | :--- | :--- |
| **External User** | Internet | Restricted access to public profile and transaction history. |
| **Internal User** | Intranet | Access to internal business logic, reporting, and CRM tools. |
| **Super Admin** | Intranet (VPN Required) | Full system configuration, audit log access, and IAM management. |
| **Service Account** | Backend / Secure Zone | Programmatic access for automated syncs and database queries. |

### 2.2 Authentication (AuthN) & Authorization (AuthZ)
* **Authentication:** * **Internet:** OIDC/OAuth 2.0 with mandatory Multi-Factor Authentication (MFA).
    * **Intranet:** SAML 2.0 Single Sign-On (SSO) integrated with corporate identity sources.
* **Authorization:** Strict Role-Based Access Control (RBAC) enforced via API Gateway and Service Mesh.
* **Identity Provider (IdP) Strategy:** Hybrid Identity Model syncing Cloud IdP with On-Premise Active Directory via secure connectors.
* **Session Management:** Short-lived tokens (15-min) with `Secure`, `HttpOnly`, and `SameSite=Strict` flags.

---

## 3. Technical Security Domains

### 3.1 Network Security
* **Perimeter Defense:** Cloud-native WAF for Internet endpoints; Stateful Inspection Firewalls for Intranet.
* **Zero Trust:** Implementation of a "Never Trust, Always Verify" model for all internal traffic.
* **Segmentation:** Distinct subnets for Web, App, and DB tiers with strictly defined Security Groups/ACLs.

### 3.2 Data Security
* **Encryption:** AES-256 for Data-at-Rest; TLS 1.3 for all Data-in-Transit.
* **Key Management:** Cloud KMS for cloud assets and Physical HSM for on-premise secrets.

---

## 4. Deployment Scenarios & Architecture Diagrams

### Scenario A: Intranet Site (Cloud) + Database (Cloud)
* **Requirement:** Complete isolation within a Cloud VPC. Communication to the database must stay on the provider's backbone using Private Link/VPC Endpoints to avoid exposure to the public internet.
```mermaid
graph LR
    subgraph Cloud_VPC
        User((Internal User)) --> App[Intranet App - Cloud]
        App --> PL((Private Link))
        PL --> DB[(Database - Cloud)]
    end

### Scenario B: Intranet Site (Cloud) + Database (On-Premise)
* **Requirement: Secure "North-South" traffic via Site-to-Site IPsec VPN or Direct Connect. The database must remain behind the corporate on-premise firewall, and the Cloud App must authenticate via a secure gateway or service principal to traverse the hybrid link.
```mermaid
graph LR
    subgraph Cloud_Zone
        App[Intranet App - Cloud]
    end
    subgraph Secure_Tunnel
        VPN{IPsec VPN / Tunnel}
    end
    subgraph On-Premise_DC
        VPN --> FW[Enterprise Firewall]
        FW --> DB[(Database - On-Prem)]
    end
    App --- VPN

### Scenario C: Intranet (On-Premise) + Database (Cloud)
* **Requirement: On-premise App acts as a trusted client. Cloud DB uses strict IP Whitelisting to allow only the corporate Data Center's public egress IP.
```mermaid
graph LR
    subgraph On-Premise_DC
        App[Intranet App - On-Prem]
    end
    subgraph Secure_Gateway
        GW[NAT / Proxy Gateway]
    end
    subgraph Cloud_Zone
        GW --> DB[(Database - Cloud)]
    end
    App --- GW
### Scenario D: Intranet (On-Premise) + Database (On-Premise)
* **Requirement: High-security local segmentation. Traffic between App and DB must be inspected by an internal Firewall/IPS to prevent lateral movement.
```mermaid
graph TD
    subgraph Corporate_LAN
        User((Internal)) --> App[Intranet App - On-Prem]
        App --> IFW[Internal Firewall / IPS]
        IFW --> DB[(Local DB - On-Prem)]
    end

## 5. Monitoring, Logging & Compliance

### 5.1 Logging Requirements
* **Audit Logs:** Capture and timestamp all successful and failed login attempts, privilege escalations, and administrative configuration changes.
* **Data Logs:** Mandatory logging of all **CRUD** (Create, Read, Update, Delete) operations performed on sensitive database tables to ensure a complete data trail.
* **Retention:** Logs must be retained for a minimum of **365 days**. Storage must be in an immutable bucket (e.g., AWS S3 with Object Lock or Azure Immutable Blob Storage) to prevent tampering.

### 5.2 SIEM Integration
* **Real-time Streaming:** All application and infrastructure logs must stream to a centralized **SIEM** (e.g., Splunk, Microsoft Sentinel, or IBM QRadar) via encrypted transport agents.
* **Correlation Rules:** The SIEM must be configured with logic to trigger immediate alerts for:
    * **"Impossible Travel":** Logins from geographically distant locations within a 1-hour window.
    * **Brute Force Patterns:** Multiple failed authentication attempts from a single source in a short duration.

### 5.3 Incident Response (IR)
* **Containment:** Implementation of automated playbooks to isolate compromised Cloud instances or On-Premise Virtual Machines (VMs) immediately upon malware detection.
* **Hybrid Link Alerts:** High-priority monitoring of connectivity; immediate notification to the Security Operations Center (SOC) if the **Site-to-Site VPN** or **Direct Connect** link between Cloud and On-Premise environments fails.



### 5.4 Compliance Standards
* **Encryption Standards:** Use of **FIPS 140-2** compliant cryptographic modules for all encryption, hashing, and digital signature tasks.
* **Regular Audits:** * **Bi-annual Penetration Testing:** External and internal security testing twice a year.
    * **Quarterly RBAC Reviews:** Periodic review of all user access rights to ensure compliance with the Principle of Least Privilege.