import http from 'k6/http';
import { check, sleep } from 'k6';
export const options = {
  stages: [
    { duration: '1m', target: 50 },
    { duration: '2m', target: 100 },
    { duration: '2m', target: 200 },
    { duration: '2m', target: 300 },
    { duration: '1m', target: 0 },
  ],
  thresholds: {
    http_req_failed: ['rate<0.05'],
  },
};
export default function () {
  if (Math.random() < 0.7) {
    const res = http.get('http://10.43.97.253/healthz');
    check(res, { 'healthz 200': (r) => r.status === 200 });
  } else {
    const payload = JSON.stringify({ feedbackText: 'load test feedback ' + Math.random() });
    const params = { headers: { 'Content-Type': 'application/json' } };
    const res = http.post('http://10.43.97.253/api/feedback', payload, params);
    check(res, { 'feedback 201': (r) => r.status === 201 });
  }
  sleep(0.5);
}
