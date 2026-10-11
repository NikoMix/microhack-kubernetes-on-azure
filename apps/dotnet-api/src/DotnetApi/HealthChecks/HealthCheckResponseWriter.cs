using System.Text.Json;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace DotnetApi.HealthChecks;

/// <summary>
/// Writes health-check results as a compact JSON document.
/// </summary>
public static class HealthCheckResponseWriter
{
    private static readonly JsonSerializerOptions SerializerOptions = new(JsonSerializerDefaults.Web);

    /// <summary>
    /// Writes the <paramref name="report"/> to the response as JSON.
    /// </summary>
    /// <param name="context">The HTTP context.</param>
    /// <param name="report">The health report.</param>
    public static Task WriteAsync(HttpContext context, HealthReport report)
    {
        ArgumentNullException.ThrowIfNull(context);
        ArgumentNullException.ThrowIfNull(report);

        context.Response.ContentType = "application/json; charset=utf-8";

        var payload = new
        {
            status = report.Status.ToString(),
            totalDurationMs = report.TotalDuration.TotalMilliseconds,
            checks = report.Entries.Select(entry => new
            {
                name = entry.Key,
                status = entry.Value.Status.ToString(),
                description = entry.Value.Description,
                durationMs = entry.Value.Duration.TotalMilliseconds,
            }),
        };

        return context.Response.WriteAsJsonAsync(payload, SerializerOptions);
    }
}
