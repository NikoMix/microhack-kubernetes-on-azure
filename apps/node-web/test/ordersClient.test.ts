import { describe, it, expect, vi, afterEach } from 'vitest';
import { getOrders, getApiHealth, OrdersClientError } from '../src/ordersClient.js';
import type { Order } from '../src/ordersClient.js';

const orders: Order[] = [
  { id: 'o-1', customer: 'Grace Hopper', sku: 'SKU-9', qty: 3, status: 'delivered' },
];

afterEach(() => {
  vi.restoreAllMocks();
});

describe('getOrders', () => {
  it('returns parsed orders on a 200 response', async () => {
    const fetchMock = vi
      .spyOn(globalThis, 'fetch')
      .mockResolvedValue(new Response(JSON.stringify(orders), { status: 200 }));

    const result = await getOrders();
    expect(result).toEqual(orders);
    expect(fetchMock).toHaveBeenCalledOnce();
    const calledUrl = fetchMock.mock.calls[0]?.[0];
    expect(typeof calledUrl).toBe('string');
    expect(calledUrl).toContain('/orders');
  });

  it('throws OrdersClientError on a non-200 response', async () => {
    vi.spyOn(globalThis, 'fetch').mockResolvedValue(new Response('nope', { status: 500 }));
    await expect(getOrders()).rejects.toBeInstanceOf(OrdersClientError);
  });

  it('throws OrdersClientError on a network failure', async () => {
    vi.spyOn(globalThis, 'fetch').mockRejectedValue(new Error('ECONNREFUSED'));
    await expect(getOrders()).rejects.toBeInstanceOf(OrdersClientError);
  });

  it('throws OrdersClientError on an unexpected payload shape', async () => {
    vi.spyOn(globalThis, 'fetch').mockResolvedValue(
      new Response(JSON.stringify({ not: 'an array' }), { status: 200 }),
    );
    await expect(getOrders()).rejects.toBeInstanceOf(OrdersClientError);
  });
});

describe('getApiHealth', () => {
  it('returns true when downstream health is ok', async () => {
    vi.spyOn(globalThis, 'fetch').mockResolvedValue(new Response('', { status: 200 }));
    await expect(getApiHealth()).resolves.toBe(true);
  });

  it('returns false when downstream health fails', async () => {
    vi.spyOn(globalThis, 'fetch').mockRejectedValue(new Error('down'));
    await expect(getApiHealth()).resolves.toBe(false);
  });
});
