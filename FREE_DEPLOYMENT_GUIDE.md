# 🆓 무료 배포 가이드 - CicdTest

GitHub Actions를 사용한 무료 Azure 배포 방법을 안내합니다.

## 🎯 무료 배포 옵션

### 1. **Azure 무료 티어 활용** (권장)

#### Azure 무료 계정 혜택
- **$200 크레딧** (12개월)
- **Static Web Apps**: 무료 (월 2GB 스토리지, 100GB 대역폭)
- **App Service F1**: 무료 (공유 인프라, 60분/일 CPU)
- **Azure Container Registry**: 무료 (500MB 스토리지)

#### 설정 방법
```bash
# 1. Azure CLI 설치
winget install Microsoft.AzureCLI  # Windows
brew install azure-cli             # macOS

# 2. Azure 로그인
az login

# 3. 무료 리소스 생성
az group create --name cicdtest-free-rg --location koreacentral

# 4. Static Web Apps 생성 (프론트엔드)
az staticwebapp create \
  --name cicdtest-frontend \
  --resource-group cicdtest-free-rg \
  --source https://github.com/99MotiveU/CicdTest \
  --location koreacentral \
  --branch main \
  --app-location "/frontend" \
  --output-location "build"

# 5. App Service Plan 생성 (F1 무료)
az appservice plan create \
  --name cicdtest-free-plan \
  --resource-group cicdtest-free-rg \
  --sku F1 \
  --location koreacentral

# 6. Web App 생성 (백엔드)
az webapp create \
  --name cicdtest-backend \
  --resource-group cicdtest-free-rg \
  --plan cicdtest-free-plan \
  --runtime "JAVA:17-java17"
```

### 2. **GitHub Pages + Railway** (완전 무료)

#### GitHub Pages (프론트엔드)
- **무료**: 정적 사이트 호스팅
- **자동 배포**: GitHub Actions로 자동 배포
- **커스텀 도메인**: 지원

#### Railway (백엔드)
- **무료**: 월 $5 크레딧
- **자동 배포**: GitHub 연동
- **데이터베이스**: PostgreSQL 무료 티어

### 3. **Vercel + Render** (완전 무료)

#### Vercel (프론트엔드)
- **무료**: 개인 프로젝트 무제한
- **자동 배포**: GitHub 연동
- **글로벌 CDN**: 자동 제공

#### Render (백엔드)
- **무료**: 월 750시간
- **자동 배포**: GitHub 연동
- **데이터베이스**: PostgreSQL 무료

### 4. **Netlify + Heroku** (제한적 무료)

#### Netlify (프론트엔드)
- **무료**: 월 100GB 대역폭
- **자동 배포**: GitHub 연동
- **폼 처리**: 무료

#### Heroku (백엔드)
- **무료**: 월 550-1000시간 (수면 모드)
- **자동 배포**: GitHub 연동
- **PostgreSQL**: 무료 10,000행

## 🚀 Azure 무료 배포 설정

### 1. GitHub Secrets 설정

GitHub 저장소 → Settings → Secrets and variables → Actions에서:

| 시크릿 이름 | 값 | 설명 |
|------------|-----|------|
| `AZURE_STATIC_WEB_APPS_API_TOKEN` | Azure Portal에서 생성 | Static Web Apps 배포 토큰 |
| `AZURE_WEBAPP_NAME` | `cicdtest-backend` | Web App 이름 |
| `AZURE_WEBAPP_PUBLISH_PROFILE` | 배포 프로필 XML | Web App 배포 프로필 |

### 2. Static Web Apps API 토큰 생성

1. Azure Portal → Static Web Apps → cicdtest-frontend
2. Settings → Manage deployment tokens
3. Generate new token
4. 토큰을 `AZURE_STATIC_WEB_APPS_API_TOKEN`에 설정

### 3. Web App 배포 프로필 생성

```bash
# 배포 프로필 다운로드
az webapp deployment list-publishing-profiles \
  --name cicdtest-backend \
  --resource-group cicdtest-free-rg \
  --xml > cicdtest-backend.publishsettings
```

### 4. 워크플로우 활성화

`free-deploy.yml` 워크플로우를 사용하여 무료 배포를 활성화합니다.

## 📊 무료 한도 비교

| 서비스 | 무료 한도 | 제한사항 |
|--------|-----------|----------|
| **Azure Static Web Apps** | 월 2GB 스토리지, 100GB 대역폭 | 충분함 |
| **Azure App Service F1** | 60분/일 CPU, 1GB RAM | 개발용 적합 |
| **GitHub Pages** | 무제한 | 정적 사이트만 |
| **Vercel** | 무제한 | 개인 프로젝트 |
| **Netlify** | 월 100GB 대역폭 | 충분함 |
| **Railway** | 월 $5 크레딧 | 소규모 프로젝트 |
| **Render** | 월 750시간 | 충분함 |
| **Heroku** | 월 550-1000시간 | 수면 모드 |

## 💡 추천 조합

### 1. **완전 무료** (개발/학습용)
- **프론트엔드**: GitHub Pages 또는 Vercel
- **백엔드**: Railway 또는 Render
- **데이터베이스**: Railway PostgreSQL 또는 Render PostgreSQL

### 2. **Azure 무료 티어** (프로덕션 준비)
- **프론트엔드**: Azure Static Web Apps
- **백엔드**: Azure App Service F1
- **데이터베이스**: Azure Database for PostgreSQL (유료)

### 3. **하이브리드** (비용 최적화)
- **프론트엔드**: Azure Static Web Apps (무료)
- **백엔드**: Railway (무료)
- **데이터베이스**: Railway PostgreSQL (무료)

## 🛠️ 무료 배포 스크립트

### Azure 무료 설정 스크립트
```bash
#!/bin/bash
# setup-free-azure.sh

echo "🆓 무료 Azure 설정 시작..."

# Azure CLI 확인
if ! command -v az &> /dev/null; then
    echo "Azure CLI 설치 필요"
    exit 1
fi

# Azure 로그인
az login

# 리소스 그룹 생성
az group create --name cicdtest-free-rg --location koreacentral

# Static Web Apps 생성
az staticwebapp create \
  --name cicdtest-frontend \
  --resource-group cicdtest-free-rg \
  --source https://github.com/99MotiveU/CicdTest \
  --location koreacentral \
  --branch main \
  --app-location "/frontend" \
  --output-location "build"

# App Service Plan 생성
az appservice plan create \
  --name cicdtest-free-plan \
  --resource-group cicdtest-free-rg \
  --sku F1 \
  --location koreacentral

# Web App 생성
az webapp create \
  --name cicdtest-backend \
  --resource-group cicdtest-free-rg \
  --plan cicdtest-free-plan \
  --runtime "JAVA:17-java17"

echo "✅ 무료 Azure 설정 완료!"
```

## 🎯 배포 URL

### Azure 무료 배포
- **Frontend**: https://cicdtest-frontend.azurestaticapps.net
- **Backend**: https://cicdtest-backend.azurewebsites.net
- **H2 Console**: https://cicdtest-backend.azurewebsites.net/h2-console

### GitHub Pages + Railway
- **Frontend**: https://99motiveu.github.io/CicdTest
- **Backend**: https://cicdtest-backend.railway.app

### Vercel + Render
- **Frontend**: https://cicdtest.vercel.app
- **Backend**: https://cicdtest-backend.onrender.com

## 💰 비용 요약

### Azure 무료 티어
- **Static Web Apps**: 무료 (월 2GB 스토리지)
- **App Service F1**: 무료 (60분/일 CPU)
- **총 비용**: $0/월

### 완전 무료 옵션
- **GitHub Pages**: 무료
- **Railway**: 무료 (월 $5 크레딧)
- **총 비용**: $0/월

## 🔒 보안 고려사항

### 무료 서비스 사용 시
1. **환경 변수**: 민감한 정보는 GitHub Secrets 사용
2. **데이터베이스**: 무료 티어는 데이터 손실 위험 있음
3. **백업**: 정기적인 데이터 백업 권장
4. **모니터링**: 무료 서비스는 제한적인 모니터링

## 📞 지원

문제가 발생하면:
1. **Azure 무료 티어**: Azure Portal → Support
2. **GitHub Pages**: GitHub Community
3. **Railway**: Railway Discord
4. **Vercel**: Vercel Support

---

**참고**: 무료 서비스는 한도가 있으므로 프로덕션 환경에서는 유료 서비스 사용을 권장합니다. 