export type OtlpProtocol = 'grpc' | 'http/protobuf';

export interface AppConfig {
  readonly port: number;
  readonly ordersApiBaseUrl: string;
  readonly otelServiceName: string;
  readonly otelExporterOtlpEndpoint: string | undefined;
  readonly otelExporterOtlpProtocol: OtlpProtocol;
  readonly appInsightsConnectionString: string | undefined;
  readonly requestTimeoutMs: number;
}

function readInt(value: string | undefined, fallback: number): number {
  if (value === undefined || value.trim() === '') {
    return fallback;
  }
  const parsed = Number.parseInt(value, 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
}

function readString(value: string | undefined, fallback: string): string {
  if (value === undefined || value.trim() === '') {
    return fallback;
  }
  return value;
}

function readOptional(value: string | undefined): string | undefined {
  if (value === undefined || value.trim() === '') {
    return undefined;
  }
  return value;
}

function readProtocol(value: string | undefined): OtlpProtocol {
  return value === 'http/protobuf' ? 'http/protobuf' : 'grpc';
}

export function loadConfig(env: NodeJS.ProcessEnv = process.env): AppConfig {
  return {
    port: readInt(env.PORT, 8080),
    ordersApiBaseUrl: readString(env.ORDERS_API_BASEURL, 'http://dotnet-api:8080'),
    otelServiceName: readString(env.OTEL_SERVICE_NAME, 'node-web'),
    otelExporterOtlpEndpoint: readOptional(env.OTEL_EXPORTER_OTLP_ENDPOINT),
    otelExporterOtlpProtocol: readProtocol(env.OTEL_EXPORTER_OTLP_PROTOCOL),
    appInsightsConnectionString: readOptional(env.APPLICATIONINSIGHTS_CONNECTION_STRING),
    requestTimeoutMs: readInt(env.REQUEST_TIMEOUT_MS, 5000),
  };
}

export const config: AppConfig = loadConfig();
