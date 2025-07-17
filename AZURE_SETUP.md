# Azure 배포 설정 가이드

이 가이드는 Spring Boot + React 게시판 애플리케이션을 Azure에 배포하기 위한 상세한 설정 방법을 설명합니다.

## 1. Azure CLI 설치 및 로그인

### Azure CLI 설치
```bash
# Windows (PowerShell)
winget install Microsoft.AzureCLI

# macOS
brew install azure-cli

# Linux (Ubuntu/Debian)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### Azure 로그인
```bash
az login
```

## 2. Azure 리소스 생성

### 리소스 그룹 생성
```bash
az group create --name board-app-rg --location koreacentral
```

### Azure Container Registry 생성
```bash
az acr create \
  --resource-group board-app-rg \
  --name boardappacr \
  --sku Basic \
  --admin-enabled true
```

### ACR 로그인 정보 확인
```bash
az acr credential show --name boardappacr
```

## 3. Azure 서비스 주체 생성

GitHub Actions에서 Azure 리소스에 접근할 수 있도록 서비스 주체를 생성합니다.

```bash
# 서비스 주체 생성
az ad sp create-for-rbac \
  --name "board-app-sp" \
  --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/board-app-rg \
  --sdk-auth
```

**중요**: `{subscription-id}`를 실제 Azure 구독 ID로 변경하세요.

구독 ID 확인 방법:
```bash
az account show --query id --output tsv
```

## 4. GitHub Secrets 설정

GitHub 저장소의 Settings > Secrets and variables > Actions에서 다음 시크릿을 설정하세요:

### AZURE_CREDENTIALS
서비스 주체 생성 시 출력된 JSON 전체를 복사하여 설정:
```json
{
  "clientId": "your-client-id",
  "clientSecret": "your-client-secret",
  "subscriptionId": "your-subscription-id",
  "tenantId": "your-tenant-id",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

### AZURE_REGISTRY
Azure Container Registry 이름:
```
boardappacr
```

### AZURE_REGISTRY_USERNAME
ACR 사용자명 (보통 ACR 이름과 동일):
```
boardappacr
```

### AZURE_REGISTRY_PASSWORD
ACR 비밀번호 (서비스 주체 생성 시 출력된 값):
```
your-acr-password
```

### AZURE_RESOURCE_GROUP
리소스 그룹 이름:
```
board-app-rg
```

### AZURE_LOCATION
Azure 지역:
```
koreacentral
```

## 5. 배포 테스트

### 수동 배포 테스트
```bash
# 배포 스크립트 실행 권한 부여
chmod +x azure-deploy.sh

# 배포 실행
./azure-deploy.sh
```

### GitHub Actions를 통한 자동 배포
1. GitHub 저장소에 코드 푸시
2. Actions 탭에서 워크플로우 진행 상황 확인
3. 배포 완료 후 제공된 URL로 접속

## 6. 배포 확인

### 컨테이너 상태 확인
```bash
az container list --resource-group board-app-rg --output table
```

### 로그 확인
```bash
# Backend 로그
az container logs --resource-group board-app-rg --name board-backend

# Frontend 로그
az container logs --resource-group board-app-rg --name board-frontend
```

### 애플리케이션 접속
```bash
# Backend URL 확인
az container show \
  --resource-group board-app-rg \
  --name board-backend \
  --query "ipAddress.fqdn" \
  --output tsv

# Frontend URL 확인
az container show \
  --resource-group board-app-rg \
  --name board-frontend \
  --query "ipAddress.fqdn" \
  --output tsv
```

## 7. 비용 관리

### 비용 확인
```bash
# 리소스 그룹별 비용 확인
az consumption usage list \
  --billing-period-name 202401 \
  --query "[?contains(instanceName, 'board-app')]"
```

### 리소스 정리 (개발 완료 후)
```bash
# 전체 리소스 그룹 삭제
az group delete --name board-app-rg --yes --no-wait
```

## 8. 문제 해결

### 일반적인 문제들

#### 1. 권한 오류
```
Error: Insufficient privileges to complete the operation
```
**해결책**: 서비스 주체에 적절한 권한 부여
```bash
az role assignment create \
  --assignee "your-service-principal-id" \
  --role "Contributor" \
  --scope "/subscriptions/{subscription-id}/resourceGroups/board-app-rg"
```

#### 2. ACR 로그인 실패
```
Error: authentication required
```
**해결책**: ACR 자격 증명 확인
```bash
az acr credential show --name boardappacr
```

#### 3. 컨테이너 시작 실패
```
Error: Container failed to start
```
**해결책**: 로그 확인 및 환경 변수 점검
```bash
az container logs --resource-group board-app-rg --name board-backend
```

### 로그 분석
```bash
# 실시간 로그 모니터링
az container logs --resource-group board-app-rg --name board-backend --follow

# 특정 시간대 로그
az container logs --resource-group board-app-rg --name board-backend --since 1h
```

## 9. 보안 고려사항

### 프로덕션 환경 설정
1. **JWT 시크릿 변경**: 기본값에서 강력한 시크릿으로 변경
2. **HTTPS 설정**: Azure Application Gateway 또는 Azure Front Door 사용
3. **네트워크 보안**: Azure Virtual Network 및 Network Security Groups 설정
4. **모니터링**: Azure Monitor 및 Application Insights 설정

### 환경 변수 관리
```bash
# 프로덕션용 환경 변수 설정
az container update \
  --resource-group board-app-rg \
  --name board-backend \
  --environment-variables \
    JWT_SECRET="your-production-secret" \
    SPRING_PROFILES_ACTIVE="prod"
```

## 10. 확장성 고려사항

### 트래픽 증가 시
1. **Azure Kubernetes Service (AKS)** 마이그레이션 고려
2. **Azure Database for PostgreSQL** 사용 (H2 대신)
3. **Azure Redis Cache** 추가
4. **Azure CDN** 설정

### 마이크로서비스 아키텍처
1. **API Gateway** 패턴 적용
2. **서비스 메시** 도입 (Istio)
3. **분산 추적** 시스템 구축

## 지원 및 문의

문제가 발생하거나 추가 도움이 필요한 경우:
1. Azure CLI 도움말: `az --help`
2. Azure 문서: https://docs.microsoft.com/azure/
3. GitHub Actions 문서: https://docs.github.com/actions 