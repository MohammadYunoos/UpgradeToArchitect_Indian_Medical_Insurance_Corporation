# IMIC – Pain Points Analysis

## 1. Performance Bottlenecks

**Observation:** The current system relies on traditional **web servers and application servers** running on VMs (IaaS), handling all policy, claims, and authentication logic.

**Pain Point:**
- Peak traffic (e.g., end of the month when many policies are purchased or claims submitted) causes slow response times.
- The system cannot elastically scale; all VMs have fixed capacity.
- Any spike in concurrent users (agents, policyholders, company staff) may overwhelm the load balancer or web/application servers.

**Impact:** Users experience latency while logging in, submitting claims, or viewing policy documents, reducing satisfaction and operational efficiency.

---

## 2. Scalability Limitations

**Observation:** The architecture is **rigid**, with predefined VMs and a single database server.

**Pain Point:**
- Adding more users or increasing the number of policies requires **manual provisioning** of additional servers.
- No auto-scaling for compute or storage, making expansion time-consuming.
- Application layer and DB layer are tightly coupled, so scaling one without impacting the other is difficult.

**Impact:** IMIC cannot quickly adapt to growth or seasonal fluctuations in claims/policy submissions.

---

## 3. Manual Processes

**Observation:** Agents manually enter customer data and upload supporting documents (medical reports, age proofs, etc.). The insurance company manually verifies and approves or rejects policies.

**Pain Point:**
- Document verification is **time-intensive** and prone to human error.
- There is no automated workflow or validation for claim/document submission.
- Manual entry of claims and policies creates duplication and delays.

**Impact:** Processing time for claims or new policies is longer, leading to dissatisfied customers and delayed payments.

---

## 4. Limited Accessibility & User Experience Issues

**Observation:** Policyholders and agents access the system over the internet or VPN, but the UI is tightly coupled to the web servers hosted in IaaS.

**Pain Point:**
- Remote users may experience slow access due to lack of CDN or caching.
- Mobile access is limited or non-responsive.
- The system’s navigation and look-and-feel are not optimized for fast access.

**Impact:** Poor user experience may discourage usage of the portal and increase support calls.

---

## 5. Single Point of Failure & Security Concerns

**Observation:** Database server is a single VM, and application servers are limited. Security is enforced via firewalls and NSGs, but modern threats are evolving.

**Pain Point:**
- If the database or a critical application server fails, the system can become unavailable.
- Disaster recovery and backup are manual or ad hoc.
- No integrated threat detection or logging for suspicious activities.

**Impact:** Risk of downtime, data loss, or security incidents; difficult for trainees or IT staff to manage efficiently.

---

## 6. Operational Overhead

**Observation:** All components (web, app, database) run on IaaS, requiring patching, monitoring, and manual scaling.

**Pain Point:**
- High administrative overhead for system updates, OS patching, and backup configuration.
- Trainees may struggle with understanding and maintaining the setup efficiently.
- Monitoring is reactive rather than proactive.

**Impact:** Increases operational costs and slows down delivery of enhancements or bug fixes.

---

## Summary Table of Pain Points

| Area | Current Issue | Impact |
|------|---------------|--------|
| Performance | Fixed VMs, overloaded under peak traffic | Slow response, user frustration |
| Scalability | No auto-scaling; manual VM provisioning | Cannot quickly adapt to growing users or claims |
| Manual Processes | Data entry & document verification by agents | Increased processing time, error-prone |
| Accessibility | Limited remote/mobile access | Poor user experience, slow adoption |
| Reliability & Security | Single DB VM, manual backups, basic firewall | Downtime risk, data loss, security exposure |
| Operations | High administrative overhead | Increased cost, slower enhancements |

---

**Conclusion:**
The current IMIC system has multiple pain points related to performance, scalability, manual processes, accessibility, security, and operational overhead. Addressing these will improve efficiency, user experience, and system reliability.