# Azure Governance Hierarchy – Design and Justification

## 1. Purpose

This document describes the proposed Azure governance hierarchy and provides clear justification for two design options.  
The design addresses cost ownership, accounting, environment separation, policy enforcement, compliance, and enterprise-wide reporting, based strictly on the provided case study requirements.

---

## 2. Key Requirements from the Case Study

- Two business units:
  - Apparel
  - Sporting Goods
- Each business unit contains three departments:
  - Product Development
  - Marketing
  - Sales
- Each business unit and department must be able to track Azure costs.
- Product Development includes a testing phase requiring lower-cost virtual machines.
- Enterprise IT must provide company-wide Azure cost reporting.
- VM naming and sizing standards must be enforced.
- Non-compliant resources must be automatically identified.

---

## 3. Azure Cost Model (Foundation)

Azure costs originate and roll up through the following hierarchy:

```
Resource → Resource Group → Subscription → Management Group → Tenant Root
```

- **Resources** generate actual charges.
- **Resource Groups** aggregate workload or department costs.
- **Subscriptions** represent cost ownership boundaries.
- **Management Groups** aggregate costs across business units.
- **Tenant Root** provides enterprise-wide visibility.

This model applies to both proposed options.

---

## 4. Option 1: Department-Level Subscriptions  
**(Business Unit → Department → Environment)**

### 4.1 Description

- Each Business Unit is represented as a Management Group.
- Each Department operates within its own Azure Subscription.
- Product Development uses separate subscriptions for:
  - Production
  - Non-Production
- Resource Groups contain complete workloads (VM and data together).
- Enterprise IT is assigned read-only and cost-management access at the Tenant Root.

---

### 4.2 Justification

- Subscriptions provide the strongest native cost boundary in Azure.
- Each department has clear and independent cost ownership.
- Budgets and alerts can be applied directly at the department level.
- Production and Non-Production environments are fully isolated.
- RBAC can be tightly controlled for Production environments.
- Azure Policies can be scoped cleanly per department or environment.
- Compliance reporting maps directly to departmental ownership.
- Enterprise IT retains visibility without owning workloads.

---

### 4.3 VM Policy Application

- **Product Development – Non-Production Subscription**
  - Azure Policy restricts allowed VM sizes to approved low-cost SKUs.
- **Product Development – Production Subscription**
  - Azure Policy enforces approved VM sizes and naming standards.
- Policies are scoped only to Product Development subscriptions.
- Marketing and Sales subscriptions are not affected.

---

### 4.4 Cost Capture by Level

| Level | Cost Captured |
|-----|--------------|
| Resource | Actual VM, storage, and service usage |
| Resource Group | Workload-level cost |
| Subscription | Department-level cost |
| Management Group | Business unit total cost |
| Tenant Root | Organization-wide cost |

---

### 4.5 Trade-offs

- Higher number of subscriptions.
- Increased administrative overhead.

This trade-off is acceptable when strong governance and accountability are required.

---

## 5. Option 2: Business-Unit Subscription with Resource Group Separation  
**(Business Unit → Subscription → Department & Environment)**

### 5.1 Description

- Each Business Unit is represented as a Management Group.
- Each Business Unit uses a single Azure Subscription.
- Departments and Product Development environments are separated using Resource Groups.
- Azure Policies and RBAC are scoped at subscription and resource-group levels.
- Enterprise IT retains tenant-level reporting access.

---

### 5.2 Justification

- Fewer subscriptions reduce operational and administrative overhead.
- Azure Cost Management supports resource group–level cost tracking.
- Departments can still monitor and control their spend.
- Production and Non-Production environments are logically separated.
- Policy enforcement remains effective at the resource group level.
- Automation and CI/CD pipelines are simpler to manage.
- Enterprise IT reporting remains unchanged.

---

### 5.3 VM Policy Application

- **Product Development – Non-Production Resource Group**
  - Azure Policy restricts VM sizes to approved low-cost SKUs.
- **Product Development – Production Resource Group**
  - Azure Policy enforces approved VM sizes and naming standards.
- Policies are scoped only to Product Development resource groups.

---

### 5.4 Cost Capture by Level

| Level | Cost Captured |
|-----|--------------|
| Resource | Actual VM, storage, and service usage |
| Resource Group | Department and environment cost |
| Subscription | Business unit total cost |
| Management Group | Aggregated business unit cost |
| Tenant Root | Organization-wide cost |

---

### 5.5 Trade-offs

- Cost accountability relies on consistent resource group discipline.
- Weaker financial isolation between departments.

This option is suitable where simplicity and agility are prioritized.

---

## 6. Enterprise IT Role (Applies to Both Options)

- Enterprise IT is assigned:
  - Reader
  - Cost Management Reader
- Scope: Tenant Root Management Group

Enterprise IT:
- Provides company-wide cost reporting.
- Monitors compliance and governance.
- Does not deploy or manage application workloads.

---

## 7. Non-Compliance Identification

- Azure Policy is used to:
  - Enforce VM sizing and naming standards.
  - Automatically identify non-compliant resources.
- Azure Policy Compliance Dashboard provides:
  - Compliance status by scope.
  - Lists of non-compliant resources.
  - Visibility for Enterprise IT and governance teams.

---

## 8. Recommendation Summary

- **Option 1** is recommended when:
  - Strong cost ownership is required.
  - Strict production isolation is critical.
  - Governance and audit requirements are high.

- **Option 2** is recommended when:
  - Operational simplicity is preferred.
  - Subscription sprawl should be minimized.
  - Departments are comfortable sharing a subscription.

Both options satisfy the case study requirements and align with Azure governance best practices.

---

## 9. Conclusion

The proposed governance hierarchies provide clear cost visibility, enforce compliance, and support enterprise-wide reporting while allowing flexibility based on organizational priorities. The final selection should be based on governance maturity, financial controls, and operational preferences.
