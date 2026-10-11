using Azure;
using Azure.AI.Inference;

namespace DotnetApi.Ai;

/// <summary>
/// <see cref="IChatInferenceProvider"/> backed by the Azure AI Inference API
/// (<see cref="ChatCompletionsClient"/>), shared by Azure AI Foundry model inference and
/// GitHub Models. Authenticates with an <see cref="AzureKeyCredential"/>.
/// </summary>
public abstract class AzureInferenceChatInferenceProvider : IChatInferenceProvider
{
    private readonly ChatCompletionsClient _client;
    private readonly string? _model;

    /// <summary>
    /// Initializes a new instance of the <see cref="AzureInferenceChatInferenceProvider"/> class.
    /// </summary>
    /// <param name="options">AI options (endpoint, model, api key/token).</param>
    protected AzureInferenceChatInferenceProvider(AiOptions options)
    {
        ArgumentNullException.ThrowIfNull(options);
        ArgumentException.ThrowIfNullOrWhiteSpace(options.Endpoint);
        ArgumentException.ThrowIfNullOrWhiteSpace(options.ApiKey);

        _client = new ChatCompletionsClient(new Uri(options.Endpoint), new AzureKeyCredential(options.ApiKey));
        _model = options.Model;
    }

    /// <inheritdoc />
    public bool IsEnabled => true;

    /// <inheritdoc />
    public async Task<string> CompleteAsync(string systemPrompt, string userPrompt, CancellationToken ct)
    {
        var requestOptions = new ChatCompletionsOptions
        {
            Messages =
            {
                new ChatRequestSystemMessage(systemPrompt),
                new ChatRequestUserMessage(userPrompt),
            },
        };

        if (!string.IsNullOrWhiteSpace(_model))
        {
            requestOptions.Model = _model;
        }

        var response = await _client.CompleteAsync(requestOptions, ct).ConfigureAwait(false);
        return response.Value.Content;
    }
}
