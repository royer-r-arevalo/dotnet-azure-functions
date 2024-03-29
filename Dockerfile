#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/azure-functions/dotnet-isolated:4-dotnet-isolated7.0 AS base
WORKDIR /home/site/wwwroot
EXPOSE 80

FROM mcr.microsoft.com/dotnet/runtime:6.0 as runtime6.0
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
# Copy .NET Core 6.0 runtime from the 6.0 image
COPY --from=runtime6.0 /usr/share/dotnet/host /usr/share/dotnet/host
COPY --from=runtime6.0 /usr/share/dotnet/shared /usr/share/dotnet/shared
WORKDIR /src
COPY ["AzureFunctions.Walkthrough.csproj", "."]
RUN dotnet restore "./AzureFunctions.Walkthrough.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "AzureFunctions.Walkthrough.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "AzureFunctions.Walkthrough.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /home/site/wwwroot
COPY --from=publish /app/publish .
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true