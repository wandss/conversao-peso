#FROM mcr.microsoft.com/dotnet/core/sdk:5.0 AS build-env
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS base
WORKDIR /app
EXPOSE 80

#FROM mcr.microsoft.com/dotnet/core/sdk AS build
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src
COPY ./ConversaoPeso.Web/ConversaoPeso.Web.csproj .
RUN dotnet restore 
COPY ./ConversaoPeso.Web/ .
RUN dotnet build ConversaoPeso.Web.csproj -c Release -o /app/build

FROM build AS publish
RUN dotnet publish ConversaoPeso.Web.csproj -c Release -o /app/publish

#FROM base AS final
FROM debian:bullseye-slim
ADD https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb packages-microsoft-prod.deb
RUN apt update && \
    apt install -y ca-certificates && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt update && \
    apt install -y apt-transport-https && \
    apt update && \
    apt install -y aspnetcore-runtime-5.0
    #apt install -y donet-sdk-5.0
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ConversaoPeso.Web.dll"]
