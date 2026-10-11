using DotnetApi.Models;

namespace DotnetApi.Repositories;

/// <summary>
/// Abstraction over order persistence. Implemented in-memory today; a database-backed
/// implementation can be swapped in without changing the endpoints.
/// </summary>
public interface IOrderRepository
{
    /// <summary>Indicates the repository has finished initializing (used by readiness checks).</summary>
    bool IsReady { get; }

    /// <summary>Lists orders, optionally filtered by <paramref name="status"/>.</summary>
    Task<IReadOnlyList<Order>> ListAsync(OrderStatus? status, CancellationToken cancellationToken = default);

    /// <summary>Gets a single order by id, or <c>null</c> if not found.</summary>
    Task<Order?> GetAsync(Guid id, CancellationToken cancellationToken = default);

    /// <summary>Creates a new order in the <see cref="OrderStatus.Pending"/> state.</summary>
    Task<Order> CreateAsync(CreateOrderRequest request, CancellationToken cancellationToken = default);

    /// <summary>Updates an order's status; returns the updated order or <c>null</c> if not found.</summary>
    Task<Order?> UpdateStatusAsync(Guid id, OrderStatus status, CancellationToken cancellationToken = default);
}
