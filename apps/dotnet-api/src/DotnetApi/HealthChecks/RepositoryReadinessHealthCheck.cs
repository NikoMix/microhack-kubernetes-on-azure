using DotnetApi.Repositories;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace DotnetApi.HealthChecks;

/// <summary>
/// Readiness check that reports healthy once the order repository has initialized.
/// </summary>
public sealed class RepositoryReadinessHealthCheck : IHealthCheck
{
    private readonly IOrderRepository _repository;

    /// <summary>
    /// Initializes a new instance of the <see cref="RepositoryReadinessHealthCheck"/> class.
    /// </summary>
    /// <param name="repository">The order repository.</param>
    public RepositoryReadinessHealthCheck(IOrderRepository repository) => _repository = repository;

    /// <inheritdoc />
    public Task<HealthCheckResult> CheckHealthAsync(
        HealthCheckContext context,
        CancellationToken cancellationToken = default)
    {
        return Task.FromResult(_repository.IsReady
            ? HealthCheckResult.Healthy("Repository initialized.")
            : HealthCheckResult.Unhealthy("Repository not initialized."));
    }
}
