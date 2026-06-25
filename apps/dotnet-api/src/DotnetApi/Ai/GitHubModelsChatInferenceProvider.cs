namespace DotnetApi.Ai;

/// <summary>
/// <see cref="IChatInferenceProvider"/> for GitHub Models, using the shared Azure AI
/// Inference <c>ChatCompletionsClient</c> (endpoint e.g. <c>https://models.github.ai/inference</c>
/// with a token credential).
/// </summary>
public sealed class GitHubModelsChatInferenceProvider : AzureInferenceChatInferenceProvider
{
    /// <summary>
    /// Initializes a new instance of the <see cref="GitHubModelsChatInferenceProvider"/> class.
    /// </summary>
    /// <param name="options">AI options (endpoint, model, token).</param>
    public GitHubModelsChatInferenceProvider(AiOptions options)
        : base(options)
    {
    }
}
