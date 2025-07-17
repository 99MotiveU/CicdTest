# CicdTest - Spring Boot + React 게시판 애플리케이션

GitHub Actions를 사용한 Azure 자동 배포가 설정된 Spring Boot + React 게시판 애플리케이션입니다.

**마지막 업데이트**: 2024년 12월 19일 - CI/CD 파이프라인 테스트

## 📍 프로젝트 정보

- **GitHub 저장소**: https://github.com/99MotiveU/CicdTest
- **프로젝트 구조**: CicdTest 디렉토리 내에 전체 소스코드 포함
- **백엔드**: Spring Boot (Java 17)
- **프론트엔드**: React (TypeScript)
- **데이터베이스**: H2 (개발용), PostgreSQL (프로덕션 권장)

## 🚀 배포 방법

### 1. GitHub Actions 자동 배포 (권장)

이 프로젝트는 GitHub Actions를 사용하여 Azure에 자동 배포됩니다.

#### 설정된 워크플로우:
- **`ci-cd-azure.yml`**: Azure Container Instances 배포
- **`deploy-frontend.yml`**: Azure Static Web Apps 배포
- **`deploy-azure-app-service.yml`**: Azure App Service 배포
- **`azure-kubernetes-deploy.yml`**: Azure Kubernetes Service 배포

#### GitHub Secrets 설정:
GitHub 저장소 → Settings → Secrets and variables → Actions에서 다음 시크릿을 설정하세요:

| 시크릿 이름 | 설명 |
|------------|------|
| `AZURE_CREDENTIALS` | Azure 서비스 주체 인증 정보 (JSON) |
| `AZURE_REGISTRY` | Azure Container Registry 이름 |
| `AZURE_REGISTRY_USERNAME` | ACR 사용자명 |
| `AZURE_REGISTRY_PASSWORD` | ACR 비밀번호 |
| `AZURE_RESOURCE_GROUP` | Azure 리소스 그룹 이름 |
| `AZURE_LOCATION` | Azure 지역 (예: koreacentral) |

#### 자동 배포 트리거:
- `main` 또는 `master` 브랜치에 푸시하면 자동 배포
- Pull Request 시 테스트 실행 및 프리뷰 환경 생성

### 2. 수동 배포

#### Azure Container Instances 배포:
```bash
# Azure CLI 로그인
az login

# 리소스 그룹 생성
az group create --name cicdtest-rg --location koreacentral

# Azure Container Registry 생성
az acr create \
  --resource-group cicdtest-rg \
  --name cicdtestacr \
  --sku Basic \
  --admin-enabled true

# 배포 스크립트 실행
chmod +x azure-deploy.sh
./azure-deploy.sh
```

#### AKS 배포:
```bash
# 환경 변수 설정
export AZURE_REGISTRY="cicdtestacr"
export AZURE_RESOURCE_GROUP="cicdtest-rg"
export AKS_CLUSTER_NAME="cicdtest-aks"

# AKS 배포 스크립트 실행
chmod +x deploy-aks.sh
./deploy-aks.sh
```

## 🏗️ 프로젝트 구조

```
CicdTest/
├── .github/workflows/          # GitHub Actions 워크플로우
│   ├── ci-cd-azure.yml        # Azure Container Instances 배포
│   ├── deploy-frontend.yml    # Static Web Apps 배포
│   ├── deploy-azure-app-service.yml  # App Service 배포
│   └── azure-kubernetes-deploy.yml   # AKS 배포
├── frontend/                   # React 프론트엔드
│   ├── src/
│   ├── public/
│   ├── package.json
│   └── Dockerfile
├── src/                        # Spring Boot 백엔드
│   ├── main/java/
│   ├── main/resources/
│   └── test/
├── k8s/                        # Kubernetes 매니페스트
│   ├── namespace.yaml
│   ├── backend-deployment.yaml
│   ├── frontend-deployment.yaml
│   ├── backend-service.yaml
│   ├── frontend-service.yaml
│   └── acr-secret.yaml
├── build.gradle               # Gradle 빌드 설정
├── Dockerfile                 # 백엔드 Docker 이미지
├── docker-compose.yml         # 로컬 개발용 Docker Compose
├── azure-deploy.sh           # Azure 배포 스크립트
├── deploy-aks.sh             # AKS 배포 스크립트
└── README.md                 # 프로젝트 문서
```

## 🛠️ 로컬 개발

### 백엔드 실행:
```bash
# Java 17 설치 필요
./gradlew bootRun
```

### 프론트엔드 실행:
```bash
cd frontend
npm install
npm start
```

### Docker Compose로 전체 실행:
```bash
docker-compose up -d
```

## 📊 모니터링

### GitHub Actions 로그:
- GitHub 저장소 → Actions 탭에서 실시간 로그 확인

### Azure 리소스 모니터링:
```bash
# 컨테이너 상태 확인
az container list --resource-group cicdtest-rg

# 로그 확인
az container logs --resource-group cicdtest-rg --name board-backend

# AKS 클러스터 상태
kubectl get nodes
kubectl get pods -n board-app
```

## 🔧 주요 기능

### 백엔드 (Spring Boot):
- JWT 기반 인증
- RESTful API
- 게시글 CRUD
- 사용자 관리
- H2 데이터베이스 (개발용)

### 프론트엔드 (React):
- 사용자 로그인/회원가입
- 게시글 목록/상세/작성/수정/삭제
- 반응형 UI
- TypeScript 사용

## 🚀 배포 URL

배포가 완료되면 다음 URL로 접속할 수 있습니다:

- **Frontend**: https://your-frontend-url
- **Backend API**: https://your-backend-url
- **H2 Console**: https://your-backend-url/h2-console

## 📚 추가 문서

- [Azure 설정 가이드](AZURE_SETUP.md)
- [GitHub Actions 가이드](GITHUB_ACTIONS_GUIDE.md)

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 📞 연락처

- **GitHub**: [99MotiveU](https://github.com/99MotiveU)
- **프로젝트 링크**: https://github.com/99MotiveU/CicdTest 