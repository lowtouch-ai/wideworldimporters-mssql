# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY wwi-app.csproj .
RUN dotnet restore
COPY . .
RUN dotnet publish wwi-app.csproj -c Release -o /app/publish

# Stage 2: Runtime — uses AppZ base (supervisord + fluentd + vault integration)
FROM appz/dotnetbase:10.0 AS final
RUN apk add --no-cache krb5-libs
WORKDIR /app
COPY --from=build /app/publish .
ENV DLL=wwi-app.dll
