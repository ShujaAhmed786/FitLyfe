# Load Testing

k6 load test scripts and reports for the FitLyfe API.

## Scripts (`k6/`)

- `load-test.js` - Baseline load: ramp to 20 users, hold 1 min
- `spike-test.js` - Spike: jump from 10 to 100 users
- `stress-test.js` - Stress: ramp to 300 users with 30% DB writes

Replace `http://10.43.97.253` with your API's ClusterIP (get it via `kubectl get svc -n fitlyfe`).

Run with: `k6 run k6/load-test.js`

## Reports

- `load-test-report.md` - Load test (1,819 req) + spike test (5,222 req) results
- `stress-test-report.md` - Advanced stress test (133,722 req, 300 users) results
