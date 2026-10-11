namespace DotnetApi.Ai;

/// <summary>
/// Default provider used when AI is disabled. Reports <see cref="IsEnabled"/> as
/// <c>false</c> and throws if a completion is requested.
/// </summary>
public sealed class DisabledChatInferenceProvider : IChatInferenceProvider
{
    /// <inheritdoc />
    public bool IsEnabled => false;

    /// <inheritdoc />
    public Task<string> CompleteAsync(string systemPrompt, string userPrompt, CancellationToken ct) =>
        throw new InvalidOperationException("AI inference is disabled. Set AI:Provider to a supported value.");
}
