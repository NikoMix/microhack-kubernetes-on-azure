namespace DotnetApi.Ai;

/// <summary>
/// <see cref="IChatInferenceProvider"/> for Azure AI Foundry model inference,
/// using the shared Azure AI Inference <c>ChatCompletionsClient</c>.
/// </summary>
public sealed class AzureAIFoundryChatInferenceProvider : AzureInferenceChatInferenceProvider
{
    /// <summary>
    /// Initializes a new instance of the <see cref="AzureAIFoundryChatInferenceProvider"/> class.
    /// </summary>
    /// <param name="options">AI options (endpoint, model, api key).</param>
    public AzureAIFoundryChatInferenceProvider(AiOptions options)
        : base(options)
    {
    }
}
