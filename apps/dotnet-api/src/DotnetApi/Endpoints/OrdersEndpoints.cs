using DotnetApi.Ai;
using DotnetApi.Models;
using DotnetApi.Repositories;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;

namespace DotnetApi.Endpoints;

/// <summary>
/// Endpoint definitions for the "orders" domain, grouped under <c>/orders</c>.
/// </summary>
public static class OrdersEndpoints
{
    private static readonly TimeSpan InsightsTimeout = TimeSpan.FromSeconds(15);

    /// <summary>
    /// Maps the orders endpoints onto the application.
    /// </summary>
    /// <param name="app">The route builder.</param>
    /// <returns>The orders route group for further configuration.</returns>
    public static RouteGroupBuilder MapOrders(this IEndpointRouteBuilder app)
    {
        ArgumentNullException.ThrowIfNull(app);

        var group = app.MapGroup("/orders").WithTags("Orders");

        group.MapGet("/", ListOrdersAsync)
            .WithName("ListOrders")
            .WithSummary("List orders, optionally filtered by status.")
            .Produces<IReadOnlyList<Order>>();

        group.MapGet("/{id:guid}", GetOrderAsync)
            .WithName("GetOrder")
            .WithSummary("Get a single order by id.")
            .Produces<Order>()
            .Produces(StatusCodes.Status404NotFound);

        group.MapPost("/", CreateOrderAsync)
            .WithName("CreateOrder")
            .WithSummary("Create a new order (status starts as Pending).")
            .Produces<Order>(StatusCodes.Status201Created)
            .ProducesValidationProblem();

        group.MapPost("/{id:guid}/status", UpdateStatusAsync)
            .WithName("UpdateOrderStatus")
            .WithSummary("Update an order's status (used by workers to mark Completed).")
            .Produces<Order>()
            .Produces(StatusCodes.Status404NotFound);

        group.MapPost("/{id:guid}/insights", GetInsightsAsync)
            .WithName("GetOrderInsights")
            .WithSummary("Generate an AI summary for an order (503 when AI is disabled).")
            .Produces<OrderInsight>()
            .Produces(StatusCodes.Status404NotFound)
            .ProducesProblem(StatusCodes.Status503ServiceUnavailable)
            .ProducesProblem(StatusCodes.Status502BadGateway);

        return group;
    }

    private static async Task<Ok<IReadOnlyList<Order>>> ListOrdersAsync(
        [FromQuery] OrderStatus? status,
        IOrderRepository repository,
        CancellationToken cancellationToken)
    {
        var orders = await repository.ListAsync(status, cancellationToken).ConfigureAwait(false);
        return TypedResults.Ok(orders);
    }

    private static async Task<Results<Ok<Order>, NotFound>> GetOrderAsync(
        Guid id,
        IOrderRepository repository,
        CancellationToken cancellationToken)
    {
        var order = await repository.GetAsync(id, cancellationToken).ConfigureAwait(false);
        return order is null ? TypedResults.NotFound() : TypedResults.Ok(order);
    }

    private static async Task<Results<Created<Order>, ValidationProblem>> CreateOrderAsync(
        CreateOrderRequest request,
        IOrderRepository repository,
        CancellationToken cancellationToken)
    {
        var errors = new Dictionary<string, string[]>();

        if (string.IsNullOrWhiteSpace(request.Customer))
        {
            errors[nameof(request.Customer)] = ["Customer is required."];
        }

        if (string.IsNullOrWhiteSpace(request.Sku))
        {
            errors[nameof(request.Sku)] = ["Sku is required."];
        }

        if (request.Quantity <= 0)
        {
            errors[nameof(request.Quantity)] = ["Quantity must be greater than zero."];
        }

        if (errors.Count > 0)
        {
            return TypedResults.ValidationProblem(errors);
        }

        var order = await repository.CreateAsync(request, cancellationToken).ConfigureAwait(false);
        return TypedResults.Created($"/orders/{order.Id}", order);
    }

    private static async Task<Results<Ok<Order>, NotFound>> UpdateStatusAsync(
        Guid id,
        UpdateStatusRequest request,
        IOrderRepository repository,
        CancellationToken cancellationToken)
    {
        var updated = await repository.UpdateStatusAsync(id, request.Status, cancellationToken).ConfigureAwait(false);
        return updated is null ? TypedResults.NotFound() : TypedResults.Ok(updated);
    }

    private static async Task<IResult> GetInsightsAsync(
        Guid id,
        IOrderRepository repository,
        IChatInferenceProvider inference,
        ILoggerFactory loggerFactory,
        CancellationToken cancellationToken)
    {
        var logger = loggerFactory.CreateLogger(typeof(OrdersEndpoints));

        var order = await repository.GetAsync(id, cancellationToken).ConfigureAwait(false);
        if (order is null)
        {
            return Results.NotFound();
        }

        if (!inference.IsEnabled)
        {
            return Results.Problem(
                statusCode: StatusCodes.Status503ServiceUnavailable,
                title: "AI inference not enabled",
                detail: "Set AI:Provider to a supported value.");
        }

        const string systemPrompt =
            "You are an operations assistant. Summarize the order in two concise sentences, " +
            "noting any risk based on its status and quantity.";
        var userPrompt =
            $"Order {order.Id}: customer '{order.Customer}', sku '{order.Sku}', " +
            $"quantity {order.Quantity}, status {order.Status}, created {order.CreatedAtUtc:O}.";

        try
        {
            using var timeoutCts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
            timeoutCts.CancelAfter(InsightsTimeout);

            var summary = await inference.CompleteAsync(systemPrompt, userPrompt, timeoutCts.Token).ConfigureAwait(false);
            return Results.Ok(new OrderInsight(order.Id, summary));
        }
        catch (Exception ex) when (ex is not OperationCanceledException || !cancellationToken.IsCancellationRequested)
        {
            Log.AiInferenceFailed(logger, ex, order.Id);
            return Results.Problem(
                statusCode: StatusCodes.Status502BadGateway,
                title: "AI inference failed",
                detail: "The upstream inference provider could not be reached or returned an error.");
        }
    }
}

/// <summary>
/// AI-generated insight for an order.
/// </summary>
/// <param name="OrderId">The order the summary refers to.</param>
/// <param name="Summary">The generated summary text.</param>
public sealed record OrderInsight(Guid OrderId, string Summary);
