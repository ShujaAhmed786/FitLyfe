# FitLyfe API Advanced Stress Test Report

**Date:** 2026-10-09
**Tool:** k6 v0.55.0
**Target:** FitLyfe API (internal ClusterIP 10.43.97.253)
**Environment:** K3s on AWS (2x t4g.small ARM64 Graviton, 2 vCPU / 2 GB each)

---

## Test Profile: Stress to Breaking Point

Progressive ramp designed to find the failure threshold:

| Stage | Duration | Target Users |
|---|---|---|
| Ramp up | 1 min | 50 |
| Hold | 2 min | 100 |
| Ramp | 2 min | 200 |
| Peak | 2 min | 300 |
| Ramp down | 1 min | 0 |

**Traffic mix:** 70% GET `/healthz` (with DB query), 30% POST `/api/feedback` (database writes)

---

## Results

| Metric | Result |
|---|---|
| Total requests | 133,722 |
| Failed requests | 0 (0.00%) |
| Checks passed | 133,722 / 133,722 (100%) |
| Avg response time | 3.46 ms |
| Median | 2.36 ms |
| p90 | 4.16 ms |
| p95 | 5.33 ms |
| Max | 620.49 ms |
| Throughput | 278.6 req/s |
| Peak concurrent users | 299 |

**Both endpoint types passed:**
- `GET /healthz` (200): passed
- `POST /api/feedback` (201, DB insert): passed

---

## Analysis

**No breaking point found.** The system handled 300 concurrent users, including 30% database write traffic, with zero failed requests.

- p95 stayed at 5.33 ms even at peak load, well within acceptable bounds
- The single max spike to 620 ms was an outlier during the steepest ramp; the system recovered immediately
- Database writes (POST /api/feedback with PostgreSQL INSERT) held up under concurrent load with no errors
- 278 requests/second sustained throughput on 2 GB ARM nodes

---

## Infrastructure

- **API:** 2 replicas, Node.js, 128 Mi request / 512 Mi limit per pod
- **Cluster:** K3s on 2x t4g.small (ARM64 Graviton, 2 vCPU / 2 GB)
- **Database:** PostgreSQL 14 + Redis on dedicated t4g.small node
- **Measured cost:** $0.64/day on AWS

---

## Conclusion

At 300 concurrent users with mixed read/write traffic, this $0.64/day setup shows no signs of stress. The breaking point is beyond 300 concurrent users. For the next round, push to 500+ or add sustained soak testing to check for memory leaks over hours.
