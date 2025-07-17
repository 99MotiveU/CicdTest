# GitHub Actions를 사용한 Azure 자동 배포 가이드

이 프로젝트는 GitHub Actions를 사용하여 Azure에 자동으로 배포하는 다양한 방법을 제공합니다.

## 🚀 사용 가능한 배포 방법

### 1. **Azure Container Instances (ACI)** - `ci-cd-azure.yml`
- **용도**: 간단한 컨테이너 배포
- **장점**: 빠른 배포, 비용 효율적
- **단점**: 확장성 제한

### 2. **Azure Static Web Apps** - `deploy-frontend.yml`
- **용도**: React 프론트엔드 전용 배포
- **장점**: 자동 HTTPS, 글로벌 CDN
- **단점**: 백엔드 지원 제한

### 3. **Azure App Service** - `deploy-azure-app-service.yml`
- **용도**: Spring Boot 백엔드 배포
- **장점**: 관리형 서비스, 자동 확장
- **단점**: 컨테이너 오케스트레이션 없음

### 4. **Azure Kubernetes Service (AKS)** - `azure-kubernetes-deploy.yml`
- **용도**: 프로덕션급 컨테이너 오케스트레이션
- **장점**: 고가용성, 자동 확장, 고급 네트워킹
- **단점**: 복잡성, 비용

## 🔧 GitHub Secrets 설정

### 필수 시크릿

| 시크릿 이름 | 설명 | 예시 값 |
|------------|------|---------|
| `AZURE_CREDENTIALS` | Azure 서비스 주체 인증 정보 | JSON 형태의 서비스 주체 정보 |
| `AZURE_REGISTRY` | Azure Container Registry 이름 | `myappacr` |
| `AZURE_REGISTRY_USERNAME` | ACR 사용자명 | `myappacr` |
| `AZURE_REGISTRY_PASSWORD` | ACR 비밀번호 | ACR에서 생성된 비밀번호 |
| `AZURE_RESOURCE_GROUP` | Azure 리소스 그룹 이름 | `myapp-rg` |
| `AZURE_LOCATION` | Azure 지역 | `koreacentral` |

### 선택적 시크릿

| 시크릿 이름 | 설명 | 사용 워크플로우 |
|------------|------|----------------|
| `AZURE_STATIC_WEB_APPS_API_TOKEN` | Static Web Apps 배포 토큰 | `deploy-frontend.yml` |
| `AZURE_WEBAPP_NAME` | App Service 이름 | `deploy-azure-app-service.yml` |
| `AZURE_WEBAPP_PUBLISH_PROFILE` | App Service 배포 프로필 | `deploy-azure-app-service.yml` |
| `AKS_CLUSTER_NAME` | AKS 클러스터 이름 | `azure-kubernetes-deploy.yml` |

## 📋 설정 단계

### 1. Azure 리소스 생성

```bash
# 리소스 그룹 생성
az group create --name myapp-rg --location koreacentral

# Azure Container Registry 생성
az acr create \
  --resource-group myapp-rg \
  --name myappacr \
  --sku Basic \
  --admin-enabled true

# 서비스 주체 생성
az ad sp create-for-rbac \
  --name "myapp-sp" \
  --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/myapp-rg \
  --sdk-auth
```

### 2. GitHub Secrets 설정

GitHub 저장소 → Settings → Secrets and variables → Actions에서 위의 시크릿들을 설정하세요.

### 3. 워크플로우 활성화

기본적으로 모든 워크플로우는 `main` 또는 `master` 브랜치에 푸시할 때 자동으로 실행됩니다.

## 🎯 배포 트리거

### 자동 배포
- `main`/`master` 브랜치에 푸시
- Pull Request 생성 (프리뷰 환경)

### 수동 배포
- GitHub Actions 탭에서 `workflow_dispatch` 이벤트 사용
- 특정 태그 생성 시 배포

## 📊 모니터링 및 로그

### GitHub Actions 로그
- GitHub 저장소 → Actions 탭에서 실시간 로그 확인
- 각 단계별 실행 상태 및 오류 메시지

### Azure 리소스 모니터링
```bash
# 컨테이너 상태 확인
az container list --resource-group myapp-rg

# 로그 확인
az container logs --resource-group myapp-rg --name board-backend

# AKS 클러스터 상태
kubectl get nodes
kubectl get pods -n board-app
```

## 🔄 배포 워크플로우

### 1. 테스트 단계
- Java 17 설정
- Gradle 빌드 및 테스트
- Node.js 빌드 (프론트엔드)

### 2. Docker 빌드
- Backend 이미지 빌드 및 ACR 푸시
- Frontend 이미지 빌드 및 ACR 푸시
- 캐시 최적화

### 3. Azure 배포
- 선택된 Azure 서비스에 배포
- 환경 변수 설정
- 헬스 체크 및 상태 확인

## 🛠️ 문제 해결

### 일반적인 문제들

#### 1. 권한 오류
```
Error: Insufficient privileges
```
**해결책**: 서비스 주체에 적절한 권한 부여

#### 2. ACR 로그인 실패
```
Error: authentication required
```
**해결책**: ACR 자격 증명 확인 및 업데이트

#### 3. 빌드 실패
```
Error: Build failed
```
**해결책**: 로컬에서 빌드 테스트 후 푸시

### 로그 확인 방법
```bash
# GitHub Actions 로그
# GitHub 웹 인터페이스에서 확인

# Azure 로그
az monitor activity-log list --resource-group myapp-rg

# AKS 로그
kubectl logs -f deployment/board-backend -n board-app
```

## 💰 비용 최적화

### 비용 확인
```bash
# 리소스 그룹별 비용
az consumption usage list \
  --billing-period-name 202401 \
  --query "[?contains(instanceName, 'myapp')]"
```

### 비용 절약 팁
1. **개발 환경**: ACI 사용 (비용 효율적)
2. **프로덕션**: AKS 사용 (확장성)
3. **정적 콘텐츠**: Static Web Apps 사용
4. **자동 스케일링**: 트래픽에 따른 자동 확장 설정

## 🔒 보안 고려사항

### 프로덕션 환경
1. **JWT 시크릿**: 강력한 시크릿 사용
2. **HTTPS**: 모든 통신 암호화
3. **네트워크 보안**: Azure Virtual Network 설정
4. **모니터링**: Azure Monitor 및 Application Insights

### 환경 변수 관리
- 민감한 정보는 GitHub Secrets 사용
- 프로덕션 환경 변수 분리
- 정기적인 시크릿 로테이션

## 📈 확장성 고려사항

### 트래픽 증가 시
1. **AKS 자동 스케일링** 설정
2. **Azure Database** 사용 (H2 대신)
3. **Azure Redis Cache** 추가
4. **Azure CDN** 설정

### 고가용성
1. **다중 가용성 영역** 설정
2. **로드 밸런서** 구성
3. **백업 및 재해 복구** 계획

## 🎉 성공적인 배포 확인

배포가 완료되면 다음을 확인하세요:

1. **헬스 체크**: 애플리케이션 접속 가능 여부
2. **기능 테스트**: 로그인, 게시글 작성 등
3. **성능 모니터링**: 응답 시간, 리소스 사용량
4. **로그 확인**: 오류 없이 정상 동작

---

**참고**: 이 가이드는 Azure CLI와 kubectl이 설치되어 있다고 가정합니다. 설치가 필요한 경우 [Azure CLI 설치 가이드](https://docs.microsoft.com/ko-kr/cli/azure/install-azure-cli)를 참조하세요. 