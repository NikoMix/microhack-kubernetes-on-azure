namespace DotnetApi.Ai;

/// <summary>
/// Abstraction over a chat-completion inference provider. Implementations are selected
/// at runtime based on <see cref="AiOptions.Provider"/>.
/// </summary>
public interface IChatInferenceProvider
{
    /// <summary>Whether the provider is configured and able to serve requests.</summary>
    bool IsEnabled { get; }

    /// <summary>
    /// Generates a completion for the supplied prompts.
    /// </summary>
    /// <param name="systemPrompt">System / instruction prompt.</param>
    /// <param name="userPrompt">User prompt.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>The model's text response.</returns>
    Task<string> CompleteAsync(string systemPrompt, string userPrompt, CancellationToken ct);
}
