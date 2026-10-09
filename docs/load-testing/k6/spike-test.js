import http from 'k6/http';
import { check, sleep } from 'k6';
export const options = {
  stages: [
    { duration: '10s', target: 10 },
    { duration: '30s', target: 100 },
    { duration: '30s', target: 100 },
    { duration: '10s', target: 0 },
  ],
};
export default function () {
  const res = http.get('http://10.43.97.253/healthz');
  check(res, { 'status is 200': (r) => r.status === 200 });
  sleep(1);
}
