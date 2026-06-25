/**
 * Telemetry bootstrap. This module performs OpenTelemetry / Azure Monitor
 * initialization as an import-time side effect so that auto-instrumentation is
 * registered BEFORE any instrumented library (http, fastify) is imported.
 *
 * It is intentionally defensive: a missing/optional dependency or an offline
 * environment must never crash the process. `startTelemetry()` is also exported
 * and is idempotent, so importing this module first and then calling it from the
 * server entrypoint is safe.
 */
import { NodeSDK } from '@opentelemetry/sdk-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { OTLPTraceExporter as OtlpGrpcExporter } from '@opentelemetry/exporter-trace-otlp-grpc';
import { OTLPTraceExporter as OtlpHttpExporter } from '@opentelemetry/exporter-trace-otlp-proto';
import { resourceFromAttributes } from '@opentelemetry/resources';
import { ATTR_SERVICE_NAME } from '@opentelemetry/semantic-conventions';
import { useAzureMonitor } from '@azure/monitor-opentelemetry';
import { config } from './config.js';

let started = false;
let sdk: NodeSDK | undefined;

function initAzureMonitor(connectionString: string): boolean {
  try {
    useAzureMonitor({
      azureMonitorExporterOptions: { connectionString },
    });
    return true;
  } catch (err: unknown) {
    process.stderr.write(`telemetry: Azure Monitor init failed: ${String(err)}\n`);
    return false;
  }
}

function initOtlp(endpoint: string): boolean {
  try {
    const exporter =
      config.otelExporterOtlpProtocol === 'http/protobuf'
        ? new OtlpHttpExporter({ url: endpoint })
        : new OtlpGrpcExporter({ url: endpoint });

    sdk = new NodeSDK({
      resource: resourceFromAttributes({
        [ATTR_SERVICE_NAME]: config.otelServiceName,
      }),
      traceExporter: exporter,
      instrumentations: [getNodeAutoInstrumentations()],
    });
    sdk.start();
    return true;
  } catch (err: unknown) {
    process.stderr.write(`telemetry: OTLP init failed: ${String(err)}\n`);
    return false;
  }
}

export function startTelemetry(): void {
  if (started) {
    return;
  }
  started = true;

  if (config.appInsightsConnectionString !== undefined) {
    if (initAzureMonitor(config.appInsightsConnectionString)) {
      process.stdout.write('telemetry: Azure Monitor enabled\n');
      return;
    }
  }

  if (config.otelExporterOtlpEndpoint !== undefined) {
    if (initOtlp(config.otelExporterOtlpEndpoint)) {
      process.stdout.write(
        `telemetry: OTLP exporter enabled (${config.otelExporterOtlpProtocol})\n`,
      );
      return;
    }
  }

  process.stdout.write('telemetry: disabled (no exporter configured)\n');
}

export async function shutdownTelemetry(): Promise<void> {
  if (sdk !== undefined) {
    try {
      await sdk.shutdown();
    } catch (err: unknown) {
      process.stderr.write(`telemetry: shutdown failed: ${String(err)}\n`);
    }
  }
}

// Import-time side effect: ensures instrumentation is registered as early as possible.
startTelemetry();
