# Governance and Compliance

## Clarification Questions and Responses

| Stakeholder Type | Clarification Question | Response | Responsible Stakeholder | Type |
|------------------|-----------------------|----------|------------------------|------|
| Insurance Company | What IRDAI-compliant criteria must be applied for approving/rejecting a policy (age, medical reports, document validity, premium payment)? |  | Underwriting / Compliance | Functional |
| Insurance Company | Should policy approval be fully manual or partly automated (document checks + final approval)? |  | Underwriting / Operations | Functional |
| Insurance Company | What supporting documents must be validated for all members (diagnostic reports, age proof, etc.) before approval? |  | Compliance Officer | Functional |
| Insurance Company | How should the premium calculation formula be parameterized based on cover, age, dependents, and IRDAI actuarial constraints? |  | Actuarial Team | Functional |
| Insurance Company | What is the exact process for claims validation (document checks, fraud checks, escalation rules)? |  | Claims Dept | Functional |
| Insurance Company | Should policyholders be automatically notified of policy/claim decisions via SMS/Email? |  | IT / Operations | Functional |
| Insurance Company | Should accepted claims automatically trigger cheque disbursement workflows? |  | Finance | Functional |
| Insurance Company | What data (policy info, personal info, claim status) should be visible as read-only to policyholders? |  | Compliance | Functional |
| Insurance Company | What audit logs must be maintained as per IRDAI (policy changes, claim decisions, financial logs)? |  | Compliance / IT Sec | Non-Functional |
| Insurance Company | What security controls are required (account lock after 3 invalid attempts, password rules, IRDAI security)? |  | IT Security | Non-Functional |
| Insurance Company | What performance & uptime SLAs must be supported during peak seasons (e.g., renewals)? |  | IT Infrastructure | Non-Functional |
| Insurance Company | What document retention timelines apply for KYC and medical records as per IRDAI? |  | Compliance | Non-Functional |
| Insurance Company | Should document storage comply with IRDAI cloud advisory & ISO 27001 security practices? |  | IT Security / Cloud Team | Non-Functional |
| Insurance Company | What approval SLAs exist for policies and claims that the system must enforce/track? |  | Operations | Non-Functional |
| Policy Holder | What details must be displayed on the policyholder’s dashboard (personal info, policy details, claim details)? |  | Customer Experience | Functional |
| Policy Holder | Should policyholders track claim statuses from submission – approval/rejection? |  | Claims Dept | Functional |
| Policy Holder | Are policyholders strictly view-only, or can they request corrections to personal information? |  | Compliance | Functional |
| Policy Holder | Should communication channels include chat, email, or ticket-based support for claims and policies? |  | Customer Support | Functional |
| Policy Holder | Should policyholders be able to download policy documents and claim receipts? |  | IT / CX Team | Functional |
| Policy Holder | Should the portal support multi-language access (English + required Indian languages)? |  | UX Team | Non-Functional |
| Policy Holder | What security level is required (OTP login, password rules, account lock)? |  | IT Security | Non-Functional |
| Policy Holder | What performance expectations exist for low-bandwidth areas (mobile-first design)? |  | UX / Infra | Non-Functional |
| Policy Holder | Are accessibility standards required (screen reader support, color contrast, WCAG)? |  | UX | Non-Functional |
| Policy Holder | Should all uploaded documents (bills, reports) be encrypted at rest & in transit? |  | IT Security | Non-Functional |
| Insurance Agent | What fields must agents capture for new policy creation (personal details, dependents, documents)? |  | Sales / Compliance | Functional |
| Insurance Agent | Should the system mandate upload of all documents before policy submission? |  | Sales Ops | Functional |
| Insurance Agent | What communication mechanisms are needed for agent – company – policyholder interactions? |  | Sales Ops | Functional |
| Insurance Agent | Should agents receive automated notifications about approvals or rejections? |  | IT / Sales Ops | Functional |
| Insurance Agent | Should agents have dashboards showing policy & claim statuses? |  | IT / Sales | Functional |
| Insurance Agent | Should commissions or incentives be calculated automatically based on policy approvals/renewals? |  | Finance / Sales | Functional |
| Insurance Agent | Should the agent portal enforce secure session handling, automatic logout, and device restrictions? |  | IT Security | Non-Functional |
| Insurance Agent | Is offline mode required for agents working in low-network regions? |  | Sales Ops / IT | Non-Functional |
| Insurance Agent | What IRDAI audit requirements exist for tracking agent activity logs? |  | Compliance | Non-Functional |
| Insurance Agent | Should the UI follow uniform look-and-feel for easy navigation as mandated in IMIC? |  | UX | Non-Functional |