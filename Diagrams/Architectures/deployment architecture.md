# Azure Deployment Architecture – IMIC

---

## Azure IaaS Deployment Diagram – IMIC Perspective (Explanation)

### Why IaaS for IMIC?

IaaS is used when IMIC requires:

- Full control over servers, operating systems, and security patches  
- A traditional **3-tier architecture** (Web, App, Database)  
- Custom compliance and security controls  

---

### How IMIC Maps to IaaS

#### Users
- Policy Holders (via Internet)
- Insurance Agents (via Internet)
- Insurance Company Staff (via Intranet / VPN)

---

#### Flow
1. Users access the IMIC portal via the Internet  
2. Traffic reaches the **Azure Load Balancer**  
3. Requests are routed internally within the **Azure Virtual Network (VNET)**  

---

#### VNET Design
- **VNET Address Space:** `10.0.0.0/16`

---

#### Subnets

**Web Subnet (`10.0.1.0/24`)**
- Web VMs hosting:
  - Policy Holder UI
  - Agent UI  

**App Subnet (`10.0.2.0/24`)**
- Application VMs hosting:
  - Policy Management
  - Claims Processing
  - Authentication Logic  

**DB Subnet (`10.0.3.0/24`)**
- SQL Server VM storing:
  - Policy data
  - Claims data
  - User data  

**Management Subnet (`10.0.4.0/24`)**
- Azure Bastion for secure administrative access  

---

#### Storage
- **Azure Blob Storage**
  - Medical reports
  - Claim documents
  - Policy documents  

---

#### Security
- Network Security Groups (NSGs) per subnet  
- Azure Firewall for perimeter protection  
- Azure Key Vault for credentials and connection strings  

---

## Azure PaaS Deployment Diagram – IMIC Perspective (Explanation)

### Why PaaS for IMIC?

PaaS is best suited for IMIC when the focus is on:

- Faster development and onboarding for trainees  
- Minimal infrastructure and OS management  
- Built-in high availability and auto-scaling  

---

### How IMIC Maps to PaaS

#### Users
- Policy Holders  
- Insurance Agents  
- Insurance Company Staff  

---

#### Flow
1. Users access the IMIC portal  
2. Traffic passes through **Azure Front Door** with **WAF and CDN**  
3. Requests are routed to Azure App Services  

---

#### Application Layer

**Azure App Service – Web App**
- Policy Holder Portal  
- Agent Portal  

**Azure App Service – API**
- Policy Management Service  
- Claims Management Service  
- Authentication Service  

---

#### Database
- **Azure SQL Database**
  - Policy data  
  - Claims data  
  - User data  

---

#### Documents
- **Azure Blob Storage**
  - Uploads from agents and policy holders  

---

#### Security
- Azure Active Directory / Azure AD B2C  
- Managed Identity for secure service access  
- HTTPS enforced  
- Web Application Firewall (WAF) protection  

---

#### Monitoring & DevOps
- Azure Application Insights  
- Azure Monitor  
- CI/CD using Azure DevOps or GitHub Actions  

---

## Key Differences – IMIC

| Area | IaaS | PaaS |
|-----|-----|-----|
| Control | Full VM control | Managed by Azure |
| Complexity | High | Low |
| Trainee Friendly | ❌ | ✅ |
| Scaling | Manual | Automatic |
| Cost Efficiency | Lower infrastructure cost, higher operations effort | Optimized |

---

