# FitLyfe API Load & Spike Test Report

**Date:** 2026-10-09
**Target:** FitLyfe calorie-tracker API (`/healthz`)
**Tool:** k6 v0.55.0
**Environment:** K3s cluster on AWS (2x t4g.small ARM64 Graviton, 2 vCPU / 2 GB each)

---

## Test 1: Load Test

**Profile:** Ramp to 20 concurrent users over 30s, hold for 1 minute, ramp down over 30s.

| Metric | Result |
|---|---|
| Total requests | 1,819 |
| Failed requests | 0 (0.00%) |
| Avg response time | 2.15 ms |
| p90 | 2.66 ms |
| p95 | 2.85 ms |
| Max | 18.28 ms |
| Throughput | 15.1 req/s |

**Verdict:** Passed. Zero failures, p95 under 3 ms.

---

## Test 2: Spike Test

**Profile:** 10 users baseline, spike to 100 concurrent users for 30s, hold, ramp down.

| Metric | Result |
|---|---|
| Total requests | 5,222 |
| Failed requests | 0 (0.00%) |
| Avg response time | 2.42 ms |
| p90 | 2.69 ms |
| p95 | 3.00 ms |
| Max | 206.96 ms (brief, recovered) |
| Throughput | 64.8 req/s |

**Verdict:** Passed. Zero failures under 5x traffic spike. Brief latency spike to 207 ms during ramp, recovered immediately with no errors.

---

## Infrastructure

- **API:** 2 replicas, Node.js, 128 Mi request / 512 Mi limit per pod
- **Cluster:** K3s on 2x t4g.small (ARM64 Graviton)
- **Database:** PostgreSQL 14 + Redis on dedicated node
- **Measured cost:** $0.64/day on AWS

---

## Conclusion

The setup handles 100 concurrent users with zero failed requests and sub-3ms p95 latency. For a 2 GB ARM node pair at $0.64/day, there is comfortable headroom before needing to scale to t4g.medium.
