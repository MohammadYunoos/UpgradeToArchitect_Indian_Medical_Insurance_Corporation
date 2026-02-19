# IMIC Threat Overview (T1–T8)


# Threat Explanations

## T1 — Credential Stuffing / MFA Fatigue Attacks
Attackers try large lists of leaked credentials to break into Policy Holder or Agent accounts. In MFA fatigue, attackers repeatedly trigger MFA pushes hoping users approve one by accident.

## T2 — JWT Replay / Token Forgery
A stolen JWT can be replayed from another device or location. Weak verification or signing practices could allow attackers to craft or alter tokens.

## T3 — IDOR (Insecure Direct Object Reference)
Attackers manipulate resource IDs to access data belonging to other policyholders.

## T4 — Malicious File Upload
Attackers upload harmful documents disguised as medical records or proofs.

## T5 — SSRF / Egress Abuse
Backend services may be tricked into sending outbound requests to internal systems or metadata endpoints.

## T6 — Database Exfiltration / Bulk Export
Malicious users may run bulk extraction operations like full‑table SELECTs or exports.

## T7 — Payment Callback Forgery
Attackers forge or intercept payment confirmation callbacks from banks or payment gateways.

## T8 — Partner SFTP Abuse / Diagnostic Lab Compromise
Lab systems may be compromised, enabling attackers to submit fake medical reports or steal medical information.

---

# Threat Table

| Threat ID | Threat Name | Description | Target Area | Risk |
|-----------|-------------|-------------|-------------|------|
| T1 | Credential Stuffing / MFA Fatigue | Mass login attempts or MFA abuse | WAF, Auth Service | High |
| T2 | JWT Replay / Token Forgery | Token reuse or manipulation | Auth Service | High |
| T3 | IDOR | Accessing unauthorized data via ID manipulation | Policy & Claims Services | High |
| T4 | Malicious File Upload | Uploading harmful/malicious files | Document Service | Medium–High |
| T5 | SSRF / Egress Abuse | Unintended outbound internal requests | Backend Microservices | High |
| T6 | Database Exfiltration | Bulk extraction of sensitive data | Claims DB, Policy DB | Critical |
| T7 | Payment Callback Forgery | Tampered payment confirmation messages | Payment Gateway Integration | High |
| T8 | Partner SFTP Abuse | Fake/malicious reports via compromised partners | Diagnostic Labs Integration | Medium–High |
