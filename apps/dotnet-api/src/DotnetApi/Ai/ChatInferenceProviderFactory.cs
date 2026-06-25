using Microsoft.Extensions.Options;

namespace DotnetApi.Ai;

/// <summary>
/// Creates the appropriate <see cref="IChatInferenceProvider"/> based on
/// <see cref="AiOptions.Provider"/>. Registered as a singleton.
/// </summary>
public static class ChatInferenceProviderFactory
{
    /// <summary>
    /// Builds an <see cref="IChatInferenceProvider"/> from the supplied options.
    /// Falls back to <see cref="DisabledChatInferenceProvider"/> when the provider is
    /// <see cref="AiProvider.Disabled"/> or misconfigured.
    /// </summary>
    /// <param name="options">Resolved AI options.</param>
    /// <param name="logger">Optional logger for misconfiguration diagnostics.</param>
    public static IChatInferenceProvider Create(AiOptions options, ILogger? logger = null)
    {
        ArgumentNullException.ThrowIfNull(options);

        try
        {
            return options.Provider switch
            {
                AiProvider.AzureOpenAI => new AzureOpenAIChatInferenceProvider(options),
                AiProvider.AzureAIFoundry => new AzureAIFoundryChatInferenceProvider(options),
                AiProvider.GitHubModels => new GitHubModelsChatInferenceProvider(options),
                _ => new DisabledChatInferenceProvider(),
            };
        }
        catch (ArgumentException ex)
        {
            if (logger is not null)
            {
                Log.AiProviderMisconfigured(logger, ex, options.Provider);
            }

            return new DisabledChatInferenceProvider();
        }
    }

    /// <summary>
    /// DI factory that resolves <see cref="AiOptions"/> and an <see cref="ILogger"/>.
    /// </summary>
    /// <param name="serviceProvider">The application service provider.</param>
    public static IChatInferenceProvider Create(IServiceProvider serviceProvider)
    {
        ArgumentNullException.ThrowIfNull(serviceProvider);
        var options = serviceProvider.GetRequiredService<IOptions<AiOptions>>().Value;
        var logger = serviceProvider.GetService<ILoggerFactory>()?.CreateLogger(typeof(ChatInferenceProviderFactory));
        return Create(options, logger);
    }
}
