import { config } from './config.js';

export interface Order {
  readonly id: string;
  readonly customer: string;
  readonly sku: string;
  readonly qty: number;
  readonly status: string;
}

export class OrdersClientError extends Error {
  public constructor(message: string, cause?: unknown) {
    super(message, cause !== undefined ? { cause } : undefined);
    this.name = 'OrdersClientError';
  }
}

function isOrder(value: unknown): value is Order {
  if (typeof value !== 'object' || value === null) {
    return false;
  }
  const candidate = value as Record<string, unknown>;
  return (
    typeof candidate.id === 'string' &&
    typeof candidate.customer === 'string' &&
    typeof candidate.sku === 'string' &&
    typeof candidate.qty === 'number' &&
    typeof candidate.status === 'string'
  );
}

async function fetchWithTimeout(url: string): Promise<Response> {
  const controller = new AbortController();
  const timer = setTimeout(() => {
    controller.abort();
  }, config.requestTimeoutMs);
  try {
    return await fetch(url, {
      signal: controller.signal,
      headers: { accept: 'application/json' },
    });
  } catch (err: unknown) {
    throw new OrdersClientError(`Network error requesting ${url}`, err);
  } finally {
    clearTimeout(timer);
  }
}

export async function getOrders(): Promise<Order[]> {
  const url = `${config.ordersApiBaseUrl}/orders`;
  const response = await fetchWithTimeout(url);
  if (!response.ok) {
    throw new OrdersClientError(`Orders API returned HTTP ${String(response.status)}`);
  }

  let payload: unknown;
  try {
    payload = await response.json();
  } catch (err: unknown) {
    throw new OrdersClientError('Orders API returned invalid JSON', err);
  }

  if (!Array.isArray(payload) || !payload.every(isOrder)) {
    throw new OrdersClientError('Orders API returned an unexpected payload shape');
  }
  return payload;
}

export async function getApiHealth(): Promise<boolean> {
  const url = `${config.ordersApiBaseUrl}/healthz`;
  try {
    const response = await fetchWithTimeout(url);
    return response.ok;
  } catch {
    return false;
  }
}
