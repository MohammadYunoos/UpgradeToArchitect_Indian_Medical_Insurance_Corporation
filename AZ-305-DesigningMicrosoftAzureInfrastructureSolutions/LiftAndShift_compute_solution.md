# Compute Solution – Lift and Shift Approach (Azure VM Scale Sets)

## Overview

This compute solution implements a **Lift and Shift migration strategy** to move the existing on-premises three-tier application to **Microsoft Azure** with minimal risk and minimal architectural change.

The solution focuses on resolving peak-hour performance bottlenecks while preserving the existing synchronous application design and database layer.

---

## Key Goals

- Improve performance during peak demand
- Eliminate hardware capacity limits
- Maintain existing application architecture
- Avoid application code refactoring
- Avoid database changes
- Enable elastic scaling

---

## Existing Challenges

1. Application servers reach performance limits during peak hours  
2. Fixed on-prem infrastructure capacity  
3. Long customer wait times  
4. High hardware maintenance effort  
5. Poor scalability

---

## Proposed Compute Architecture

### Front-End Tier
- Azure Virtual Machine Scale Set (VMSS)
- Hosts IIS and .NET Core Web Application
- Autoscale based on CPU utilization and request volume
- Handles customer-facing traffic

### Middle Tier
- Azure Virtual Machine Scale Set (VMSS)
- Hosts business logic layer
- Synchronous request processing
- Scales independently from front-end tier

### Back-End Tier
- Existing SQL Server
- No migration or modernization required
- Maintains current performance and data structure

### Monitoring & Observability
- Azure Monitor
- Log Analytics
- Metrics for health checks and autoscaling

---

## Request Flow
User Request → Front-End VM Scale Set → Middle Tier VM Scale Set (Synchronous Processing) → Existing SQL Server → Response to User
If wait time exceeds threshold → Email notification


---

## How This Solves the Problem

| Challenge | Resolution |
|----------|-----------|
| Peak load bottlenecks | Elastic autoscaling |
| Fixed capacity | On-demand resources |
| Long wait times | Automatic scale-out |
| Idle hardware | Scale-in during low usage |
| Maintenance overhead | Cloud-managed compute |

---

## Tier-Specific Benefits

### Front-End Tier Benefits

- Handles traffic spikes automatically
- Prevents IIS performance saturation
- Maintains fast response times
- Requires no application changes
- Reduces overprovisioning during idle periods

---

### Middle Tier Benefits

- Scales independently to match processing demand
- Eliminates business logic bottlenecks
- Maintains synchronous workflow
- Improves throughput and stability

---

### Combined Tier Impact

| Area | On-Prem | Azure VM Scale Sets |
|-----|--------|------------------|
| Capacity | Fixed | Elastic |
| Performance | Limited | Auto-scaled |
| Maintenance | Manual | Managed |
| Availability | Hardware dependent | High resilience |
| Cost efficiency | Low | Improved via scale-in |

---

## Autoscaling Strategy

- Scale out during peak hours
- Scale in during idle hours
- Maintain minimum instance count for availability
- Metrics:
  - CPU usage
  - Request load

---

## Why Lift and Shift Is the Best Fit

- Preserves existing IIS-based architecture
- Requires minimal migration effort
- Low risk
- Fast implementation
- Meets synchronous processing needs
- Avoids unnecessary redesign

---

## Trade-Offs

### Advantages

- Minimal application changes
- No database changes
- Predictable performance
- Elastic scalability
- Operational simplicity
- High availability

### Limitations

- Compute cost during idle hours
- Always-on VM instances
- Not fully cloud-native optimized
- VM-level scaling granularity

---

## Cost vs Performance Balance

This approach prioritizes:

**Stability, performance, and rapid migration**

over

**maximum cost optimization**

---

## Future Improvement Opportunities

- Migrate front-end to Azure App Service
- Introduce asynchronous processing for high-volume workloads
- Implement caching for frequent reads
- Modernize database to managed services

---

## Final Recommendation

A Lift and Shift architecture using Azure VM Scale Sets provides the optimal balance of performance, scalability, and migration safety while preserving the existing application and database design.

---

## One-Line Summary

This solution trades higher infrastructure cost for predictable performance, elastic scaling, and minimal architectural change.