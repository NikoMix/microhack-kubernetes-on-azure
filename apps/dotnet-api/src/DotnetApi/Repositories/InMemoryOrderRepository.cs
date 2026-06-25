using System.Collections.Concurrent;
using DotnetApi.Models;

namespace DotnetApi.Repositories;

/// <summary>
/// Thread-safe, in-memory <see cref="IOrderRepository"/> backed by a
/// <see cref="ConcurrentDictionary{TKey,TValue}"/>. Seeded with sample data.
/// </summary>
public sealed class InMemoryOrderRepository : IOrderRepository
{
    private readonly ConcurrentDictionary<Guid, Order> _orders = new();
    private readonly TimeProvider _timeProvider;

    /// <summary>
    /// Initializes a new instance of the <see cref="InMemoryOrderRepository"/> class
    /// and seeds it with a small set of sample orders.
    /// </summary>
    /// <param name="timeProvider">Time abstraction used for timestamps.</param>
    public InMemoryOrderRepository(TimeProvider? timeProvider = null)
    {
        _timeProvider = timeProvider ?? TimeProvider.System;
        Seed();
        IsReady = true;
    }

    /// <inheritdoc />
    public bool IsReady { get; }

    /// <inheritdoc />
    public Task<IReadOnlyList<Order>> ListAsync(OrderStatus? status, CancellationToken cancellationToken = default)
    {
        IReadOnlyList<Order> result = _orders.Values
            .Where(o => status is null || o.Status == status)
            .OrderByDescending(o => o.CreatedAtUtc)
            .ToList();

        return Task.FromResult(result);
    }

    /// <inheritdoc />
    public Task<Order?> GetAsync(Guid id, CancellationToken cancellationToken = default)
    {
        _orders.TryGetValue(id, out var order);
        return Task.FromResult(order);
    }

    /// <inheritdoc />
    public Task<Order> CreateAsync(CreateOrderRequest request, CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(request);

        var now = _timeProvider.GetUtcNow();
        var order = new Order(
            Guid.NewGuid(),
            request.Customer.Trim(),
            request.Sku.Trim(),
            request.Quantity,
            OrderStatus.Pending,
            now,
            now);

        _orders[order.Id] = order;
        return Task.FromResult(order);
    }

    /// <inheritdoc />
    public Task<Order?> UpdateStatusAsync(Guid id, OrderStatus status, CancellationToken cancellationToken = default)
    {
        if (!_orders.TryGetValue(id, out var existing))
        {
            return Task.FromResult<Order?>(null);
        }

        var updated = existing with { Status = status, UpdatedAtUtc = _timeProvider.GetUtcNow() };
        _orders[id] = updated;
        return Task.FromResult<Order?>(updated);
    }

    private void Seed()
    {
        var now = _timeProvider.GetUtcNow();
        var samples = new[]
        {
            new Order(Guid.Parse("11111111-1111-1111-1111-111111111111"), "Contoso", "SKU-LAPTOP-14", 2, OrderStatus.Pending, now.AddMinutes(-50), now.AddMinutes(-50)),
            new Order(Guid.Parse("22222222-2222-2222-2222-222222222222"), "Fabrikam", "SKU-MOUSE-PRO", 10, OrderStatus.Processing, now.AddMinutes(-40), now.AddMinutes(-20)),
            new Order(Guid.Parse("33333333-3333-3333-3333-333333333333"), "Adventure Works", "SKU-KEYB-MX", 5, OrderStatus.Completed, now.AddMinutes(-30), now.AddMinutes(-5)),
            new Order(Guid.Parse("44444444-4444-4444-4444-444444444444"), "Northwind", "SKU-MONITOR-27", 3, OrderStatus.Cancelled, now.AddMinutes(-25), now.AddMinutes(-10)),
            new Order(Guid.Parse("55555555-5555-5555-5555-555555555555"), "Tailspin Toys", "SKU-DOCK-USB4", 1, OrderStatus.Pending, now.AddMinutes(-10), now.AddMinutes(-10)),
        };

        foreach (var order in samples)
        {
            _orders[order.Id] = order;
        }
    }
}
