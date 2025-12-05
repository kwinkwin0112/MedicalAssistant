# --- Giai đoạn Build ---
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy các file csproj và restore (để tận dụng cache)
COPY ["MedicalAssistant.API/MedicalAssistant.API.csproj", "MedicalAssistant.API/"]
COPY ["MedicalAssistant.Application/MedicalAssistant.Application.csproj", "MedicalAssistant.Application/"]
COPY ["MedicalAssistant.Domain/MedicalAssistant.Domain.csproj", "MedicalAssistant.Domain/"]
COPY ["MedicalAssistant.Infrastructure/MedicalAssistant.Infrastructure.csproj", "MedicalAssistant.Infrastructure/"]

RUN dotnet restore "MedicalAssistant.API/MedicalAssistant.API.csproj"

# Copy toàn bộ code còn lại
COPY . .
WORKDIR "/src/MedicalAssistant.API"
RUN dotnet build -c Release -o /app/build

# Publish ra file DLL
FROM build AS publish
RUN dotnet publish -c Release -o /app/publish

# --- Giai đoạn Run ---
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app
EXPOSE 8080
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "MedicalAssistant.API.dll"]