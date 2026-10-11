namespace DotnetApi.Models;

/// <summary>
/// Lifecycle status of an <see cref="Order"/>.
/// </summary>
public enum OrderStatus
{
    /// <summary>Order created, not yet picked up for processing.</summary>
    Pending,

    /// <summary>Order is being processed by a worker.</summary>
    Processing,

    /// <summary>Order has been fulfilled.</summary>
    Completed,

    /// <summary>Order was cancelled.</summary>
    Cancelled,
}

/// <summary>
/// An order in the "orders" domain.
/// </summary>
/// <param name="Id">Unique identifier.</param>
/// <param name="Customer">Customer name or identifier.</param>
/// <param name="Sku">Stock-keeping unit being ordered.</param>
/// <param name="Quantity">Quantity ordered; always greater than zero.</param>
/// <param name="Status">Current lifecycle status.</param>
/// <param name="CreatedAtUtc">Creation timestamp (UTC).</param>
/// <param name="UpdatedAtUtc">Last update timestamp (UTC).</param>
public sealed record Order(
    Guid Id,
    string Customer,
    string Sku,
    int Quantity,
    OrderStatus Status,
    DateTimeOffset CreatedAtUtc,
    DateTimeOffset UpdatedAtUtc);
