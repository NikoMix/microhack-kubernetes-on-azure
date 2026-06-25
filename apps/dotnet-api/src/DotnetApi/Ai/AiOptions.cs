namespace DotnetApi.Ai;

/// <summary>
/// Supported chat inference providers. Inference is <see cref="Disabled"/> by default,
/// honoring the course standing rule that AI is opt-in.
/// </summary>
public enum AiProvider
{
    /// <summary>No inference provider; AI endpoints return 503.</summary>
    Disabled,

    /// <summary>Azure OpenAI Service.</summary>
    AzureOpenAI,

    /// <summary>Azure AI Foundry model inference.</summary>
    AzureAIFoundry,

    /// <summary>GitHub Models.</summary>
    GitHubModels,
}

/// <summary>
/// Options for the modular AI inference capability, bound from the <c>AI</c> configuration section.
/// </summary>
public sealed class AiOptions
{
    /// <summary>Configuration section name.</summary>
    public const string SectionName = "AI";

    /// <summary>Selected provider. Defaults to <see cref="AiProvider.Disabled"/>.</summary>
    public AiProvider Provider { get; set; } = AiProvider.Disabled;

    /// <summary>Service/endpoint URI (provider-specific).</summary>
    public string? Endpoint { get; set; }

    /// <summary>Model id (Azure AI Foundry / GitHub Models).</summary>
    public string? Model { get; set; }

    /// <summary>Deployment name (Azure OpenAI).</summary>
    public string? DeploymentName { get; set; }

    /// <summary>API key or token, typically injected from env or Key Vault.</summary>
    public string? ApiKey { get; set; }
}
