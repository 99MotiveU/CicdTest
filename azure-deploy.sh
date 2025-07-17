#!/bin/bash

# Azure 배포 스크립트
# 이 스크립트는 Azure Container Registry와 Azure Container Instances를 설정합니다.

set -e

# 변수 설정
RESOURCE_GROUP="board-app-rg"
LOCATION="koreacentral"
ACR_NAME="boardappacr"
BACKEND_IMAGE="board-backend"
FRONTEND_IMAGE="board-frontend"

echo "🚀 Azure 배포를 시작합니다..."

# 1. 리소스 그룹 생성
echo "📦 리소스 그룹을 생성합니다..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# 2. Azure Container Registry 생성
echo "🏗️ Azure Container Registry를 생성합니다..."
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic \
  --admin-enabled true

# 3. ACR 로그인 정보 가져오기
echo "🔐 ACR 로그인 정보를 가져옵니다..."
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query "username" --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" --output tsv)

echo "ACR 사용자명: $ACR_USERNAME"
echo "ACR 비밀번호: $ACR_PASSWORD"

# 4. Docker 이미지 빌드 및 푸시
echo "🐳 Docker 이미지를 빌드하고 ACR에 푸시합니다..."

# Backend 이미지 빌드 및 푸시
echo "🔧 Backend 이미지를 빌드합니다..."
docker build -t $ACR_NAME.azurecr.io/$BACKEND_IMAGE:latest .
docker push $ACR_NAME.azurecr.io/$BACKEND_IMAGE:latest

# Frontend 이미지 빌드 및 푸시
echo "📱 Frontend 이미지를 빌드합니다..."
docker build -t $ACR_NAME.azurecr.io/$FRONTEND_IMAGE:latest ./frontend
docker push $ACR_NAME.azurecr.io/$FRONTEND_IMAGE:latest

# 5. Azure Container Instances 배포
echo "🚀 Azure Container Instances에 배포합니다..."

# Backend 컨테이너 배포
echo "🔧 Backend 컨테이너를 배포합니다..."
az container create \
  --resource-group $RESOURCE_GROUP \
  --name board-backend \
  --image $ACR_NAME.azurecr.io/$BACKEND_IMAGE:latest \
  --dns-name-label board-backend-$(date +%s) \
  --ports 8080 \
  --registry-login-server $ACR_NAME.azurecr.io \
  --registry-username $ACR_USERNAME \
  --registry-password $ACR_PASSWORD \
  --environment-variables \
    SPRING_PROFILES_ACTIVE=prod \
    SPRING_DATASOURCE_URL=jdbc:h2:mem:testdb \
    SPRING_DATASOURCE_DRIVERCLASSNAME=org.h2.Driver \
    SPRING_DATASOURCE_USERNAME=sa \
    SPRING_DATASOURCE_PASSWORD= \
    SPRING_H2_CONSOLE_ENABLED=true \
    SPRING_JPA_HIBERNATE_DDL_AUTO=create-drop \
    SPRING_JPA_SHOW_SQL=true \
    JWT_SECRET=your-secret-key-here \
    JWT_EXPIRATION=86400000 \
  --restart-policy Always

# Frontend 컨테이너 배포
echo "📱 Frontend 컨테이너를 배포합니다..."
az container create \
  --resource-group $RESOURCE_GROUP \
  --name board-frontend \
  --image $ACR_NAME.azurecr.io/$FRONTEND_IMAGE:latest \
  --dns-name-label board-frontend-$(date +%s) \
  --ports 3000 \
  --registry-login-server $ACR_NAME.azurecr.io \
  --registry-username $ACR_USERNAME \
  --registry-password $ACR_PASSWORD \
  --environment-variables \
    REACT_APP_API_URL=http://board-backend-$(date +%s).$LOCATION.azurecontainer.io:8080 \
  --restart-policy Always

# 6. 배포 결과 확인
echo "✅ 배포가 완료되었습니다!"
echo ""
echo "📊 배포 정보:"
echo "리소스 그룹: $RESOURCE_GROUP"
echo "위치: $LOCATION"
echo "ACR: $ACR_NAME.azurecr.io"
echo ""

# 컨테이너 상태 확인
echo "🔍 컨테이너 상태를 확인합니다..."
az container list --resource-group $RESOURCE_GROUP --output table

echo ""
echo "🌐 애플리케이션 URL:"
BACKEND_URL=$(az container show --resource-group $RESOURCE_GROUP --name board-backend --query "ipAddress.fqdn" --output tsv)
FRONTEND_URL=$(az container show --resource-group $RESOURCE_GROUP --name board-frontend --query "ipAddress.fqdn" --output tsv)

echo "📱 Frontend: http://$FRONTEND_URL:3000"
echo "🔧 Backend: http://$BACKEND_URL:8080"
echo "📊 H2 Console: http://$BACKEND_URL:8080/h2-console"
echo ""
echo "🎉 배포가 성공적으로 완료되었습니다!" 