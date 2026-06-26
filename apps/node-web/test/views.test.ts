import { describe, it, expect } from 'vitest';
import { renderStatusPage, renderErrorState, escapeHtml } from '../src/views.js';
import type { Order } from '../src/ordersClient.js';

const sampleOrders: Order[] = [
  { id: 'o-1', customer: 'Ada Lovelace', sku: 'SKU-100', qty: 2, status: 'shipped' },
  { id: 'o-2', customer: 'Alan Turing', sku: 'SKU-200', qty: 5, status: 'pending' },
];

describe('escapeHtml', () => {
  it('escapes all dangerous characters', () => {
    expect(escapeHtml(`<script>"&'`)).toBe('&lt;script&gt;&quot;&amp;&#39;');
  });
});

describe('renderStatusPage', () => {
  it('renders a row per order with healthy badge', () => {
    const html = renderStatusPage({ orders: sampleOrders, apiHealthy: true });
    expect(html).toContain('<!doctype html>');
    expect(html).toContain('API healthy');
    expect(html).toContain('Ada Lovelace');
    expect(html).toContain('Alan Turing');
    expect(html).toContain('SKU-100');
    // two data rows
    const rowCount = (html.match(/<tr>/g) ?? []).length;
    // header row + 2 data rows
    expect(rowCount).toBe(3);
  });

  it('escapes dynamic order values to prevent injection', () => {
    const malicious: Order[] = [
      {
        id: '<b>1</b>',
        customer: '<script>alert(1)</script>',
        sku: 'a&b',
        qty: 1,
        status: 'pending',
      },
    ];
    const html = renderStatusPage({ orders: malicious, apiHealthy: true });
    expect(html).not.toContain('<script>alert(1)</script>');
    expect(html).toContain('&lt;script&gt;alert(1)&lt;/script&gt;');
    expect(html).toContain('a&amp;b');
  });

  it('shows the unhealthy badge and error state when provided', () => {
    const html = renderStatusPage({ orders: [], apiHealthy: false, error: 'boom' });
    expect(html).toContain('API unavailable');
    expect(html).toContain('boom');
    expect(html).toContain('Downstream orders service is unavailable');
  });
});

describe('renderErrorState', () => {
  it('escapes the message', () => {
    expect(renderErrorState('<x>')).toContain('&lt;x&gt;');
  });
});
