/**
 * Container healthcheck. Probes the local /health endpoint and exits 0 on
 * success, 1 otherwise. Designed to run under the distroless nodejs image whose
 * ENTRYPOINT is `node`, so no shell is required.
 */
const PORT = process.env.PORT ?? '8080';
const url = `http://localhost:${PORT}/health`;
const TIMEOUT_MS = 2000;

async function main(): Promise<number> {
  const controller = new AbortController();
  const timer = setTimeout(() => {
    controller.abort();
  }, TIMEOUT_MS);
  try {
    const response = await fetch(url, { signal: controller.signal });
    return response.ok ? 0 : 1;
  } catch {
    return 1;
  } finally {
    clearTimeout(timer);
  }
}

const code = await main();
process.exit(code);
