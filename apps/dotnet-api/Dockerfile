# syntax=docker/dockerfile:1

# ---- build stage ----
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY global.json Directory.Build.props ./
COPY src/DotnetApi/DotnetApi.csproj src/DotnetApi/
RUN dotnet restore src/DotnetApi/DotnetApi.csproj
COPY src/ src/
RUN dotnet publish src/DotnetApi/DotnetApi.csproj -c Release -o /app/publish /p:UseAppHost=false

# ---- runtime stage (chiseled, non-root) ----
FROM mcr.microsoft.com/dotnet/aspnet:10.0-noble-chiseled AS final
WORKDIR /app
COPY --from=build /app/publish .

ENV ASPNETCORE_HTTP_PORTS=8080 \
    ASPNETCORE_URLS=http://0.0.0.0:8080 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    OTEL_SERVICE_NAME=dotnet-api

EXPOSE 8080

# Chiseled images ship a non-root 'app' user (uid 1654) referenced by $APP_UID.
USER $APP_UID

# Shell-less healthcheck via the app's built-in CLI probe.
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD ["dotnet", "DotnetApi.dll", "healthcheck"]

ENTRYPOINT ["dotnet", "DotnetApi.dll"]
