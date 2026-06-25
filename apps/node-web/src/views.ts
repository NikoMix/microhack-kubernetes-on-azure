import type { Order } from './ordersClient.js';

export function escapeHtml(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

const STATUS_COLOURS: Readonly<Record<string, string>> = {
  pending: '#b8860b',
  processing: '#1d6fb8',
  shipped: '#6a3fb5',
  delivered: '#1f8a4c',
  cancelled: '#c0392b',
};

function statusColour(status: string): string {
  return STATUS_COLOURS[status.toLowerCase()] ?? '#555555';
}

const STYLE = `
  :root { color-scheme: light dark; }
  * { box-sizing: border-box; }
  body { font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif; margin: 0; padding: 2rem; background: #0f1419; color: #e6e6e6; }
  .wrap { max-width: 960px; margin: 0 auto; }
  header { display: flex; align-items: center; justify-content: space-between; gap: 1rem; flex-wrap: wrap; margin-bottom: 1.5rem; }
  h1 { font-size: 1.5rem; margin: 0; }
  .badge { font-size: 0.85rem; font-weight: 600; padding: 0.35rem 0.75rem; border-radius: 999px; color: #fff; }
  .badge.up { background: #1f8a4c; }
  .badge.down { background: #c0392b; }
  table { width: 100%; border-collapse: collapse; background: #161b22; border-radius: 8px; overflow: hidden; }
  th, td { text-align: left; padding: 0.65rem 0.9rem; border-bottom: 1px solid #2a2f37; }
  th { background: #1f2630; font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.05em; }
  tr:last-child td { border-bottom: none; }
  .pill { display: inline-block; padding: 0.2rem 0.6rem; border-radius: 999px; color: #fff; font-size: 0.8rem; }
  .error { background: #2b1b1b; border: 1px solid #c0392b; padding: 1rem 1.25rem; border-radius: 8px; }
  .muted { color: #8b949e; font-size: 0.85rem; margin-top: 1.5rem; }
`;

function layout(title: string, body: string): string {
  return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>${escapeHtml(title)}</title>
<style>${STYLE}</style>
</head>
<body>
<div class="wrap">
${body}
</div>
</body>
</html>
`;
}

function healthBadge(apiHealthy: boolean): string {
  return apiHealthy
    ? '<span class="badge up">API healthy</span>'
    : '<span class="badge down">API unavailable</span>';
}

function ordersTable(orders: readonly Order[]): string {
  if (orders.length === 0) {
    return '<p class="muted">No orders to display.</p>';
  }
  const rows = orders
    .map((order) => {
      const colour = statusColour(order.status);
      return `<tr>
<td>${escapeHtml(order.id)}</td>
<td>${escapeHtml(order.customer)}</td>
<td>${escapeHtml(order.sku)}</td>
<td>${escapeHtml(String(order.qty))}</td>
<td><span class="pill" style="background:${colour}">${escapeHtml(order.status)}</span></td>
</tr>`;
    })
    .join('\n');

  return `<table>
<thead>
<tr><th>ID</th><th>Customer</th><th>SKU</th><th>Qty</th><th>Status</th></tr>
</thead>
<tbody>
${rows}
</tbody>
</table>`;
}

export interface StatusPageModel {
  readonly orders: readonly Order[];
  readonly apiHealthy: boolean;
  readonly error?: string;
}

export function renderStatusPage(model: StatusPageModel): string {
  const body = `<header>
<h1>MicroHack Orders &mdash; Front Door</h1>
${healthBadge(model.apiHealthy)}
</header>
${model.error !== undefined ? renderErrorState(model.error) : ordersTable(model.orders)}
<p class="muted">Served by node-web &middot; ${escapeHtml(new Date().toISOString())}</p>`;
  return layout('MicroHack Orders', body);
}

export function renderErrorState(message: string): string {
  return `<div class="error">
<strong>Downstream orders service is unavailable.</strong>
<p>${escapeHtml(message)}</p>
</div>`;
}
