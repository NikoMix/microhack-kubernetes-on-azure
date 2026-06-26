using DotnetApi.Ai;

namespace DotnetApi;

/// <summary>
/// High-performance, source-generated log messages (satisfies CA1848).
/// </summary>
internal static partial class Log
{
    [LoggerMessage(
        EventId = 1000,
        Level = LogLevel.Warning,
        Message = "AI provider {Provider} is selected but misconfigured; inference will be disabled.")]
    public static partial void AiProviderMisconfigured(ILogger logger, Exception exception, AiProvider provider);

    [LoggerMessage(
        EventId = 1001,
        Level = LogLevel.Error,
        Message = "AI inference failed for order {OrderId}.")]
    public static partial void AiInferenceFailed(ILogger logger, Exception exception, Guid orderId);
}
