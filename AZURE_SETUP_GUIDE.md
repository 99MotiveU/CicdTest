# Azure 설정 완전 가이드 - CicdTest

GitHub Actions를 사용한 Azure 자동 배포를 위한 Azure 설정 가이드입니다.

## 🔧 사전 준비사항

### 1. Azure CLI 설치

#### Windows (PowerShell)
```powershell
# winget 사용 (권장)
winget install Microsoft.AzureCLI

# 또는 Chocolatey 사용
choco install azure-cli
```

#### macOS
```bash
# Homebrew 사용
brew install azure-cli
```

#### Linux (Ubuntu/Debian)
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### 2. Azure CLI 로그인
```bash
az login
```
브라우저가 열리면 Azure 계정으로 로그인하세요.

## 🚀 Azure 리소스 생성

### 1. 구독 확인
```bash
# 현재 구독 확인
az account show

# 구독 목록 확인
az account list --output table

# 구독 ID 확인 (나중에 필요)
az account show --query id --output tsv
```

### 2. 리소스 그룹 생성
```bash
# 리소스 그룹 생성
az group create \
  --name cicdtest-rg \
  --location koreacentral \
  --tags project=cicdtest environment=production
```

### 3. Azure Container Registry (ACR) 생성
```bash
# ACR 생성
az acr create \
  --resource-group cicdtest-rg \
  --name cicdtestacr \
  --sku Basic \
  --admin-enabled true \
  --location koreacentral

# ACR 로그인 정보 확인
az acr credential show --name cicdtestacr
```

### 4. 서비스 주체 생성 (GitHub Actions용)
```bash
# 구독 ID 가져오기
SUBSCRIPTION_ID=$(az account show --query id --output tsv)

# 서비스 주체 생성
az ad sp create-for-rbac \
  --name "cicdtest-sp" \
  --role contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/cicdtest-rg \
  --sdk-auth
```

**중요**: 위 명령어 실행 후 출력되는 JSON을 복사해두세요. 이것이 `AZURE_CREDENTIALS` 시크릿입니다.

## 🔐 GitHub Secrets 설정

GitHub 저장소 → Settings → Secrets and variables → Actions에서 다음 시크릿을 설정하세요:

### 필수 시크릿

| 시크릿 이름 | 값 | 설명 |
|------------|-----|------|
| `AZURE_CREDENTIALS` | 서비스 주체 생성 시 출력된 JSON 전체 | Azure 인증 정보 |
| `AZURE_REGISTRY` | `cicdtestacr` | ACR 이름 |
| `AZURE_REGISTRY_USERNAME` | `cicdtestacr` | ACR 사용자명 |
| `AZURE_REGISTRY_PASSWORD` | ACR 비밀번호 | ACR 비밀번호 |
| `AZURE_RESOURCE_GROUP` | `cicdtest-rg` | 리소스 그룹 이름 |
| `AZURE_LOCATION` | `koreacentral` | Azure 지역 |

### ACR 비밀번호 확인 방법
```bash
az acr credential show --name cicdtestacr --query "passwords[0].value" --output tsv
```

## 🧪 설정 확인

### 1. Azure 리소스 확인
```bash
# 리소스 그룹 확인
az group show --name cicdtest-rg

# ACR 확인
az acr show --name cicdtestacr --resource-group cicdtest-rg

# 서비스 주체 확인
az ad sp list --display-name "cicdtest-sp" --query "[].{appId:appId, displayName:displayName}"
```

### 2. 권한 확인
```bash
# 서비스 주체 권한 확인
az role assignment list \
  --assignee "cicdtest-sp" \
  --resource-group cicdtest-rg
```

## 🚀 배포 테스트

### 1. 수동 배포 테스트
```bash
# 배포 스크립트 실행 권한 부여
chmod +x azure-deploy.sh

# 배포 실행
./azure-deploy.sh
```

### 2. GitHub Actions 자동 배포
1. GitHub 저장소에 코드 푸시
2. Actions 탭에서 워크플로우 진행 상황 확인
3. 배포 완료 후 제공된 URL로 접속

## 📊 배포 확인

### 컨테이너 상태 확인
```bash
az container list --resource-group cicdtest-rg --output table
```

### 로그 확인
```bash
# Backend 로그
az container logs --resource-group cicdtest-rg --name cicdtest-backend

# Frontend 로그
az container logs --resource-group cicdtest-rg --name cicdtest-frontend
```

### 애플리케이션 접속
```bash
# Backend URL 확인
az container show \
  --resource-group cicdtest-rg \
  --name cicdtest-backend \
  --query "ipAddress.fqdn" \
  --output tsv

# Frontend URL 확인
az container show \
  --resource-group cicdtest-rg \
  --name cicdtest-frontend \
  --query "ipAddress.fqdn" \
  --output tsv
```

## 💰 비용 관리

### 비용 확인
```bash
# 리소스 그룹별 비용 확인
az consumption usage list \
  --billing-period-name 202401 \
  --query "[?contains(instanceName, 'cicdtest')]"
```

### 예상 비용 (월)
- **Azure Container Registry (Basic)**: ~$5
- **Azure Container Instances**: ~$15-30 (사용량에 따라)
- **총 예상 비용**: ~$20-35/월

## 🛠️ 문제 해결

### 일반적인 문제들

#### 1. 권한 오류
```
Error: Insufficient privileges to complete the operation
```
**해결책**: 서비스 주체에 적절한 권한 부여
```bash
az role assignment create \
  --assignee "cicdtest-sp" \
  --role "Contributor" \
  --scope "/subscriptions/{subscription-id}/resourceGroups/cicdtest-rg"
```

#### 2. ACR 로그인 실패
```
Error: authentication required
```
**해결책**: ACR 자격 증명 확인
```bash
az acr credential show --name cicdtestacr
```

#### 3. 컨테이너 시작 실패
```
Error: Container failed to start
```
**해결책**: 로그 확인 및 환경 변수 점검
```bash
az container logs --resource-group cicdtest-rg --name cicdtest-backend
```

### 로그 분석
```bash
# 실시간 로그 모니터링
az container logs --resource-group cicdtest-rg --name cicdtest-backend --follow

# 특정 시간대 로그
az container logs --resource-group cicdtest-rg --name cicdtest-backend --since 1h
```

## 🔒 보안 고려사항

### 프로덕션 환경 설정
1. **JWT 시크릿 변경**: 기본값에서 강력한 시크릿으로 변경
2. **HTTPS 설정**: Azure Application Gateway 또는 Azure Front Door 사용
3. **네트워크 보안**: Azure Virtual Network 및 Network Security Groups 설정
4. **모니터링**: Azure Monitor 및 Application Insights 설정

### 환경 변수 관리
```bash
# 프로덕션용 환경 변수 설정
az container update \
  --resource-group cicdtest-rg \
  --name cicdtest-backend \
  --environment-variables \
    JWT_SECRET="your-production-secret" \
    SPRING_PROFILES_ACTIVE="prod"
```

## 🧹 리소스 정리

### 개발 완료 후 리소스 삭제
```bash
# 전체 리소스 그룹 삭제 (주의: 모든 리소스가 삭제됩니다)
az group delete --name cicdtest-rg --yes --no-wait

# 개별 리소스 삭제
az container delete --resource-group cicdtest-rg --name cicdtest-backend --yes
az container delete --resource-group cicdtest-rg --name cicdtest-frontend --yes
az acr delete --name cicdtestacr --resource-group cicdtest-rg --yes
```

## 📞 지원

문제가 발생하면 다음을 확인하세요:
1. Azure CLI 버전: `az version`
2. 구독 상태: `az account show`
3. 리소스 그룹 상태: `az group show --name cicdtest-rg`
4. GitHub Actions 로그: GitHub 웹 인터페이스에서 확인

---

**참고**: 이 가이드는 Azure CLI와 kubectl이 설치되어 있다고 가정합니다. 