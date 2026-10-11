using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using DotnetApi.Models;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

namespace DotnetApi.Tests;

public sealed class OrdersApiTests : IClassFixture<WebApplicationFactory<Program>>
{
    private static readonly JsonSerializerOptions JsonOptions = CreateJsonOptions();

    private readonly WebApplicationFactory<Program> _factory;

    public OrdersApiTests(WebApplicationFactory<Program> factory) => _factory = factory;

    private static JsonSerializerOptions CreateJsonOptions()
    {
        var options = new JsonSerializerOptions(JsonSerializerDefaults.Web);
        options.Converters.Add(new JsonStringEnumConverter());
        return options;
    }

    [Fact]
    public async Task GetOrders_ReturnsSeededOrders()
    {
        var client = _factory.CreateClient();

        var orders = await client.GetFromJsonAsync<List<Order>>("/orders", JsonOptions);

        Assert.NotNull(orders);
        Assert.True(orders!.Count >= 5);
    }

    [Fact]
    public async Task GetOrders_FilterByStatus_ReturnsOnlyMatching()
    {
        var client = _factory.CreateClient();

        var orders = await client.GetFromJsonAsync<List<Order>>("/orders?status=Pending", JsonOptions);

        Assert.NotNull(orders);
        Assert.NotEmpty(orders!);
        Assert.All(orders!, o => Assert.Equal(OrderStatus.Pending, o.Status));
    }

    [Fact]
    public async Task PostOrder_ValidRequest_Returns201WithLocationAndPending()
    {
        var client = _factory.CreateClient();
        var request = new CreateOrderRequest("Globex", "SKU-NEW-1", 4);

        var response = await client.PostAsJsonAsync("/orders", request, JsonOptions);

        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        Assert.NotNull(response.Headers.Location);

        var created = await response.Content.ReadFromJsonAsync<Order>(JsonOptions);
        Assert.NotNull(created);
        Assert.Equal(OrderStatus.Pending, created!.Status);
        Assert.Equal("Globex", created.Customer);
        Assert.NotEqual(Guid.Empty, created.Id);
    }

    [Theory]
    [InlineData("", "SKU-1", 1)]
    [InlineData("Customer", "", 1)]
    [InlineData("Customer", "SKU-1", 0)]
    [InlineData("Customer", "SKU-1", -3)]
    public async Task PostOrder_InvalidRequest_Returns400ValidationProblem(string customer, string sku, int quantity)
    {
        var client = _factory.CreateClient();
        var request = new CreateOrderRequest(customer, sku, quantity);

        var response = await client.PostAsJsonAsync("/orders", request, JsonOptions);

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        Assert.Contains("application/problem+json", response.Content.Headers.ContentType?.MediaType);
    }

    [Fact]
    public async Task GetOrderById_UnknownId_Returns404()
    {
        var client = _factory.CreateClient();

        var response = await client.GetAsync($"/orders/{Guid.NewGuid()}");

        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task GetOrderById_KnownId_Returns200()
    {
        var client = _factory.CreateClient();
        var created = await CreateOrderAsync(client);

        var fetched = await client.GetFromJsonAsync<Order>($"/orders/{created.Id}", JsonOptions);

        Assert.NotNull(fetched);
        Assert.Equal(created.Id, fetched!.Id);
    }

    [Fact]
    public async Task PostStatus_KnownId_TransitionsStatus()
    {
        var client = _factory.CreateClient();
        var created = await CreateOrderAsync(client);

        var response = await client.PostAsJsonAsync($"/orders/{created.Id}/status", new UpdateStatusRequest(OrderStatus.Completed), JsonOptions);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var updated = await response.Content.ReadFromJsonAsync<Order>(JsonOptions);
        Assert.NotNull(updated);
        Assert.Equal(OrderStatus.Completed, updated!.Status);
        Assert.True(updated.UpdatedAtUtc >= created.UpdatedAtUtc);
    }

    [Fact]
    public async Task PostStatus_UnknownId_Returns404()
    {
        var client = _factory.CreateClient();

        var response = await client.PostAsJsonAsync($"/orders/{Guid.NewGuid()}/status", new UpdateStatusRequest(OrderStatus.Completed), JsonOptions);

        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task Healthz_Returns200()
    {
        var client = _factory.CreateClient();

        var response = await client.GetAsync("/healthz");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Readyz_Returns200()
    {
        var client = _factory.CreateClient();

        var response = await client.GetAsync("/readyz");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task Insights_WhenAiDisabled_Returns503()
    {
        var client = _factory.CreateClient();
        var created = await CreateOrderAsync(client);

        var response = await client.PostAsync($"/orders/{created.Id}/insights", content: null);

        Assert.Equal(HttpStatusCode.ServiceUnavailable, response.StatusCode);
    }

    private static async Task<Order> CreateOrderAsync(HttpClient client)
    {
        var response = await client.PostAsJsonAsync("/orders", new CreateOrderRequest("Initech", "SKU-T-1", 2), JsonOptions);
        response.EnsureSuccessStatusCode();
        var order = await response.Content.ReadFromJsonAsync<Order>(JsonOptions);
        Assert.NotNull(order);
        return order!;
    }
}
