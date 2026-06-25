using System.ClientModel;
using Azure.AI.OpenAI;
using OpenAI.Chat;

namespace DotnetApi.Ai;

/// <summary>
/// <see cref="IChatInferenceProvider"/> backed by Azure OpenAI Service.
/// </summary>
public sealed class AzureOpenAIChatInferenceProvider : IChatInferenceProvider
{
    private readonly ChatClient _chatClient;

    /// <summary>
    /// Initializes a new instance of the <see cref="AzureOpenAIChatInferenceProvider"/> class.
    /// </summary>
    /// <param name="options">AI options (endpoint, deployment name, api key).</param>
    public AzureOpenAIChatInferenceProvider(AiOptions options)
    {
        ArgumentNullException.ThrowIfNull(options);
        ArgumentException.ThrowIfNullOrWhiteSpace(options.Endpoint);
        ArgumentException.ThrowIfNullOrWhiteSpace(options.DeploymentName);
        ArgumentException.ThrowIfNullOrWhiteSpace(options.ApiKey);

        var client = new AzureOpenAIClient(new Uri(options.Endpoint), new ApiKeyCredential(options.ApiKey));
        _chatClient = client.GetChatClient(options.DeploymentName);
    }

    /// <inheritdoc />
    public bool IsEnabled => true;

    /// <inheritdoc />
    public async Task<string> CompleteAsync(string systemPrompt, string userPrompt, CancellationToken ct)
    {
        ChatMessage[] messages =
        [
            new SystemChatMessage(systemPrompt),
            new UserChatMessage(userPrompt),
        ];

        var completion = await _chatClient.CompleteChatAsync(messages, cancellationToken: ct).ConfigureAwait(false);
        return string.Concat(completion.Value.Content.Select(part => part.Text));
    }
}
