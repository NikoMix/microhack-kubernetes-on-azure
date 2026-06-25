using Azure.Monitor.OpenTelemetry.AspNetCore;
using OpenTelemetry.Logs;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;

namespace DotnetApi.Observability;

/// <summary>
/// Wires up OpenTelemetry traces, metrics, and logs in a modular, graceful way:
/// <list type="bullet">
///   <item>Azure Monitor distro when <c>APPLICATIONINSIGHTS_CONNECTION_STRING</c> is set.</item>
///   <item>OTLP exporter when <c>OTEL_EXPORTER_OTLP_ENDPOINT</c> is set.</item>
///   <item>Otherwise instrumentation only — never throws when nothing is configured.</item>
/// </list>
/// </summary>
public static class TelemetryExtensions
{
    /// <summary>
    /// Adds OpenTelemetry to the application builder.
    /// </summary>
    /// <param name="builder">The web application builder.</param>
    /// <returns>The same builder for chaining.</returns>
    public static WebApplicationBuilder AddAppTelemetry(this WebApplicationBuilder builder)
    {
        ArgumentNullException.ThrowIfNull(builder);

        var configuration = builder.Configuration;
        var serviceName = configuration["OTEL_SERVICE_NAME"] ?? "dotnet-api";
        var appInsightsConnectionString = configuration["APPLICATIONINSIGHTS_CONNECTION_STRING"];
        var otlpEndpoint = configuration["OTEL_EXPORTER_OTLP_ENDPOINT"];

        var otel = builder.Services.AddOpenTelemetry()
            .ConfigureResource(resource => resource.AddService(
                serviceName: serviceName,
                serviceVersion: typeof(TelemetryExtensions).Assembly.GetName().Version?.ToString() ?? "1.0.0"));

        if (!string.IsNullOrWhiteSpace(appInsightsConnectionString))
        {
            // Azure Monitor distribution configures traces, metrics, and logs.
            otel.UseAzureMonitor();
            return builder;
        }

        otel
            .WithTracing(tracing => tracing
                .AddAspNetCoreInstrumentation()
                .AddHttpClientInstrumentation())
            .WithMetrics(metrics => metrics
                .AddAspNetCoreInstrumentation()
                .AddHttpClientInstrumentation()
                .AddRuntimeInstrumentation());

        if (!string.IsNullOrWhiteSpace(otlpEndpoint))
        {
            otel
                .WithTracing(tracing => tracing.AddOtlpExporter())
                .WithMetrics(metrics => metrics.AddOtlpExporter());

            builder.Logging.AddOpenTelemetry(logging =>
            {
                logging.IncludeFormattedMessage = true;
                logging.IncludeScopes = true;
                logging.AddOtlpExporter();
            });
        }

        return builder;
    }
}
