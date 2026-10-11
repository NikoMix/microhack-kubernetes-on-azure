// IMPORTANT: telemetry must be imported first so OpenTelemetry auto-instrumentation
// is registered before Fastify (and its http/undici deps) are evaluated.
import { startTelemetry, shutdownTelemetry } from './telemetry.js';

startTelemetry();

import Fastify from 'fastify';
import type { FastifyInstance } from 'fastify';
import { fileURLToPath } from 'node:url';
import { config } from './config.js';
import { getApiHealth, getOrders, OrdersClientError } from './ordersClient.js';
import { renderStatusPage } from './views.js';

export function buildServer(): FastifyInstance {
  const app = Fastify({
    logger: true,
    disableRequestLogging: false,
  });

  app.get('/health', () => {
    return { status: 'ok' };
  });

  app.get('/', async (_request, reply) => {
    const [ordersResult, apiHealthy] = await Promise.all([
      getOrders().then(
        (orders) => ({ ok: true as const, orders }),
        (err: unknown) => ({ ok: false as const, err }),
      ),
      getApiHealth(),
    ]);

    reply.type('text/html; charset=utf-8');

    if (ordersResult.ok) {
      return renderStatusPage({ orders: ordersResult.orders, apiHealthy });
    }

    const message =
      ordersResult.err instanceof OrdersClientError
        ? ordersResult.err.message
        : 'Unexpected error contacting the orders service.';
    app.log.warn({ err: ordersResult.err }, 'failed to load orders');
    // Keep the front door up: still return 200 with an error state page.
    return renderStatusPage({ orders: [], apiHealthy, error: message });
  });

  return app;
}

async function start(): Promise<void> {
  const app = buildServer();

  const close = (signal: string): void => {
    app.log.info({ signal }, 'shutting down');
    void app
      .close()
      .then(() => shutdownTelemetry())
      .then(() => {
        process.exit(0);
      })
      .catch((err: unknown) => {
        app.log.error({ err }, 'error during shutdown');
        process.exit(1);
      });
  };
  process.on('SIGTERM', () => {
    close('SIGTERM');
  });
  process.on('SIGINT', () => {
    close('SIGINT');
  });

  try {
    await app.listen({ host: '0.0.0.0', port: config.port });
  } catch (err: unknown) {
    app.log.error({ err }, 'failed to start server');
    process.exit(1);
  }
}

const entryPath = process.argv[1] ?? '';
const isMain = entryPath !== '' && fileURLToPath(import.meta.url) === entryPath;

if (isMain) {
  void start();
}
