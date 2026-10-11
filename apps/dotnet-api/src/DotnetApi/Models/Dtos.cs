namespace DotnetApi.Models;

/// <summary>
/// Request payload to create a new order.
/// </summary>
/// <param name="Customer">Customer name or identifier (required).</param>
/// <param name="Sku">Stock-keeping unit (required).</param>
/// <param name="Quantity">Quantity ordered; must be greater than zero.</param>
public sealed record CreateOrderRequest(string Customer, string Sku, int Quantity);

/// <summary>
/// Request payload to update an order's status.
/// </summary>
/// <param name="Status">The new status to apply.</param>
public sealed record UpdateStatusRequest(OrderStatus Status);
