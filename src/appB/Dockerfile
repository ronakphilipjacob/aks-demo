# Use the official .NET runtime as the base image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

# Accept build argument for Application Insights instrumentation key
ARG APPINSIGHTS_INSTRUMENTATION_KEY
ENV APPINSIGHTS_INSTRUMENTATION_KEY=${APPINSIGHTS_INSTRUMENTATION_KEY}

# Use the SDK image to build the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["AppB.csproj", "."]
RUN dotnet restore "./AppB.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "AppB.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "AppB.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Final stage/image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Create a non-root user
RUN adduser --disabled-password --gecos '' --shell /bin/bash --uid 1001 appuser
RUN chown -R appuser:appuser /app
USER appuser

ENTRYPOINT ["dotnet", "AppB.dll"]