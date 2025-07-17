#!/bin/bash

# Azure Kubernetes Service 배포 스크립트
# 사용법: ./deploy-aks.sh

set -e

echo "🚀 Azure Kubernetes Service 배포 시작..."

# 환경 변수 확인
if [ -z "$AZURE_REGISTRY" ]; then
    echo "❌ AZURE_REGISTRY 환경 변수가 설정되지 않았습니다."
    exit 1
fi

if [ -z "$AZURE_RESOURCE_GROUP" ]; then
    echo "❌ AZURE_RESOURCE_GROUP 환경 변수가 설정되지 않았습니다."
    exit 1
fi

if [ -z "$AKS_CLUSTER_NAME" ]; then
    echo "❌ AKS_CLUSTER_NAME 환경 변수가 설정되지 않았습니다."
    exit 1
fi

echo "📋 배포 정보:"
echo "  - ACR: $AZURE_REGISTRY"
echo "  - 리소스 그룹: $AZURE_RESOURCE_GROUP"
echo "  - AKS 클러스터: $AKS_CLUSTER_NAME"

# AKS 클러스터 생성 (없는 경우)
echo "🔧 AKS 클러스터 확인 중..."
if ! az aks show --resource-group $AZURE_RESOURCE_GROUP --name $AKS_CLUSTER_NAME &> /dev/null; then
    echo "📦 AKS 클러스터 생성 중..."
    az aks create \
        --resource-group $AZURE_RESOURCE_GROUP \
        --name $AKS_CLUSTER_NAME \
        --node-count 2 \
        --node-vm-size Standard_B2s \
        --enable-addons monitoring \
        --generate-ssh-keys \
        --attach-acr $AZURE_REGISTRY
else
    echo "✅ AKS 클러스터가 이미 존재합니다."
fi

# AKS 자격 증명 가져오기
echo "🔑 AKS 자격 증명 가져오기..."
az aks get-credentials \
    --resource-group $AZURE_RESOURCE_GROUP \
    --name $AKS_CLUSTER_NAME \
    --overwrite-existing

# ACR 로그인 정보로 Docker config 생성
echo "🐳 ACR Docker config 생성..."
ACR_PASSWORD=$(az acr credential show --name $AZURE_REGISTRY --query "passwords[0].value" -o tsv)
ACR_DOCKER_CONFIG=$(echo -n "{\"auths\":{\"$AZURE_REGISTRY.azurecr.io\":{\"username\":\"$AZURE_REGISTRY\",\"password\":\"$ACR_PASSWORD\",\"email\":\"\",\"auth\":\"$(echo -n "$AZURE_REGISTRY:$ACR_PASSWORD" | base64)\"}}}" | base64 -w 0)

# Kubernetes 매니페스트 업데이트
echo "📝 Kubernetes 매니페스트 업데이트..."
sed -i "s|ACR_NAME|$AZURE_REGISTRY|g" k8s/*.yaml
sed -i "s|ACR_DOCKER_CONFIG_JSON|$ACR_DOCKER_CONFIG|g" k8s/acr-secret.yaml

# 네임스페이스 생성
echo "📁 네임스페이스 생성..."
kubectl apply -f k8s/namespace.yaml

# ACR Secret 생성
echo "🔐 ACR Secret 생성..."
kubectl apply -f k8s/acr-secret.yaml

# 애플리케이션 배포
echo "🚀 애플리케이션 배포..."
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml
kubectl apply -f k8s/frontend-service.yaml

# 배포 상태 확인
echo "⏳ 배포 상태 확인 중..."
kubectl rollout status deployment/board-backend -n board-app
kubectl rollout status deployment/board-frontend -n board-app

# 서비스 URL 확인
echo "🌐 서비스 URL 확인..."
echo "Backend Service:"
kubectl get service board-backend-service -n board-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
echo ""

echo "Frontend Service:"
kubectl get service board-frontend-service -n board-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
echo ""

echo "✅ AKS 배포 완료!"
echo "📊 대시보드 접속: az aks browse --resource-group $AZURE_RESOURCE_GROUP --name $AKS_CLUSTER_NAME" 