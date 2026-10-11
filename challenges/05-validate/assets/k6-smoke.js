import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

// k6 is open-source, and Azure Load Testing can run this same plain JavaScript script.
// Set BASE_URL to the node-web BFF endpoint, for example: BASE_URL=https://app.example.com k6 run assets/k6-smoke.js
const baseUrl = (__ENV.BASE_URL || '').replace(/\/$/, '');
const orderPath = __ENV.ORDER_PATH || '/orders';
const healthPath = __ENV.HEALTH_PATH || '/health';

export const errorRate = new Rate('http_errors');

export const options = {
  vus: Number(__ENV.VUS || 5),
  duration: __ENV.DURATION || '2m',
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_errors: ['rate<0.01'],
    checks: ['rate>0.99'],
  },
};

export default function () {
  if (!baseUrl) {
    throw new Error('BASE_URL is required, for example BASE_URL=https://<node-web-hostname>');
  }

  const health = http.get(`${baseUrl}${healthPath}`, {
    tags: { scenario: 'health' },
  });

  const healthOk = check(health, {
    'health endpoint returns 200': (response) => response.status === 200,
  });

  errorRate.add(!healthOk);

  const payload = JSON.stringify({
    sku: 'trainer-kit',
    quantity: 1,
    customerId: `m5-k6-${__VU}-${__ITER}`,
  });

  const order = http.post(`${baseUrl}${orderPath}`, payload, {
    headers: { 'content-type': 'application/json' },
    tags: { scenario: 'order-flow' },
  });

  const orderOk = check(order, {
    'order request is accepted': (response) => response.status >= 200 && response.status < 300,
    'order response is not empty': (response) => response.body && response.body.length > 0,
  });

  errorRate.add(!orderOk);
  sleep(1);
}
