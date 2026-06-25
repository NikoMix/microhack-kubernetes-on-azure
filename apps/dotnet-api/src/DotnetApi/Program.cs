using System.Text.Json.Serialization;
using DotnetApi.Ai;
using DotnetApi.Endpoints;
using DotnetApi.HealthChecks;
using DotnetApi.Observability;
using DotnetApi.Repositories;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Scalar.AspNetCore;

// ---------------------------------------------------------------------------
// Healthcheck CLI mode: when invoked as `dotnet DotnetApi.dll healthcheck`
// (used by the Docker HEALTHCHECK in a shell-less chiseled image), probe the
// liveness endpoint and exit without starting Kestrel.
// ---------------------------------------------------------------------------
if (args.Contains("healthcheck", StringComparer.OrdinalIgnoreCase))
{
    return await HealthCheckCli.RunAsync().ConfigureAwait(false);
}

var builder = WebApplication.CreateBuilder(args);

// Default to listening on all interfaces, port 8080, when not otherwise configured.
if (string.IsNullOrWhiteSpace(builder.Configuration["ASPNETCORE_URLS"]) &&
    string.IsNullOrWhiteSpace(builder.Configuration["ASPNETCORE_HTTP_PORTS"]))
{
    builder.WebHost.UseUrls("http://0.0.0.0:8080");
}

// Structured JSON console logging in production.
if (builder.Environment.IsProduction())
{
    builder.Logging.ClearProviders();
    builder.Logging.AddJsonConsole(o => o.IncludeScopes = true);
}

// OpenTelemetry (traces + metrics + logs) — modular and graceful.
builder.AddAppTelemetry();

// JSON: serialize enums as strings for friendly payloads.
builder.Services.ConfigureHttpJsonOptions(options =>
    options.SerializerOptions.Converters.Add(new JsonStringEnumConverter()));

// Options + AI inference provider (disabled by default).
builder.Services.AddOptions<AiOptions>()
    .Bind(builder.Configuration.GetSection(AiOptions.SectionName))
    .ValidateOnStart();
builder.Services.AddSingleton<IChatInferenceProvider>(ChatInferenceProviderFactory.Create);

// Domain services.
builder.Services.AddSingleton<IOrderRepository, InMemoryOrderRepository>();

// Health checks — tagged "live" and "ready".
builder.Services.AddHealthChecks()
    .AddCheck("self", () => HealthCheckResult.Healthy("Process alive."), tags: ["live"])
    .AddCheck<RepositoryReadinessHealthCheck>("repository", tags: ["ready"]);

// OpenAPI document.
builder.Services.AddOpenApi();

var app = builder.Build();

// OpenAPI + Scalar API reference UI at the application root.
app.MapOpenApi();
app.MapScalarApiReference(options => options.WithTitle("Orders API — dotnet-api"));
app.MapGet("/", () => Results.Redirect("/scalar")).ExcludeFromDescription();

// Health endpoints (JSON responses).
app.MapHealthChecks("/healthz", new()
{
    Predicate = check => check.Tags.Contains("live"),
    ResponseWriter = HealthCheckResponseWriter.WriteAsync,
}).WithName("Liveness");

app.MapHealthChecks("/health", new()
{
    Predicate = check => check.Tags.Contains("live"),
    ResponseWriter = HealthCheckResponseWriter.WriteAsync,
}).WithName("LivenessAlias");

app.MapHealthChecks("/readyz", new()
{
    Predicate = check => check.Tags.Contains("ready"),
    ResponseWriter = HealthCheckResponseWriter.WriteAsync,
}).WithName("Readiness");

// Orders domain endpoints.
app.MapOrders();

await app.RunAsync().ConfigureAwait(false);
return 0;

/// <summary>
/// Lightweight liveness probe used by the container HEALTHCHECK.
/// </summary>
internal static class HealthCheckCli
{
    /// <summary>Performs a GET against the local liveness endpoint.</summary>
    /// <returns>0 when healthy (HTTP 200), otherwise 1.</returns>
    public static async Task<int> RunAsync()
    {
        try
        {
            using var http = new HttpClient { Timeout = TimeSpan.FromSeconds(2) };
            using var response = await http.GetAsync(new Uri("http://127.0.0.1:8080/healthz"))
                .ConfigureAwait(false);
            return response.IsSuccessStatusCode ? 0 : 1;
        }
        catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException)
        {
            return 1;
        }
    }
}

/// <summary>
/// Program entry point marker, exposed for <c>WebApplicationFactory</c> in tests.
/// </summary>
public partial class Program;
