# Spring Boot + React 게시판 애플리케이션

Spring Boot와 React를 사용하여 만든 게시판 애플리케이션입니다.

> **GitHub 저장소**: https://github.com/99MotiveU/CicdTest-main

## 기능

- **사용자 관리**: 회원가입, 로그인, 로그아웃
- **게시글 관리**: 게시글 작성, 조회, 수정, 삭제 (CRUD)
- **게시글 검색**: 제목과 내용으로 게시글 검색
- **페이지네이션**: 게시글 목록 페이지네이션
- **JWT 인증**: 토큰 기반 인증 시스템

## 기술 스택

### Backend
- Spring Boot 3.5.3
- Spring Security
- Spring Data JPA
- H2 Database
- JWT (JSON Web Token)
- Gradle

### Frontend
- React 18
- TypeScript
- React Router
- Axios
- CSS3

## 실행 방법

### 1. 로컬 개발 환경

#### Backend 실행
```bash
./gradlew bootRun
```

#### Frontend 실행
```bash
cd frontend
npm install
npm start
```

### 2. Docker를 사용한 실행

```bash
# 전체 애플리케이션 실행
docker-compose up --build

# 백그라운드 실행
docker-compose up -d --build
```

### 3. Azure 클라우드 배포

#### 사전 요구사항
- Azure CLI 설치
- Azure 구독
- Docker 설치

#### Azure 배포 방법

1. **Azure CLI 로그인**
```bash
az login
```

2. **배포 스크립트 실행**
```bash
chmod +x azure-deploy.sh
./azure-deploy.sh
```

3. **GitHub Actions를 통한 자동 배포**
   - GitHub 저장소의 Settings > Secrets에서 다음 시크릿 설정:
     - `AZURE_CREDENTIALS`: Azure 서비스 주체 자격 증명
     - `AZURE_REGISTRY`: Azure Container Registry 이름
     - `AZURE_REGISTRY_USERNAME`: ACR 사용자명
     - `AZURE_REGISTRY_PASSWORD`: ACR 비밀번호
     - `AZURE_RESOURCE_GROUP`: 리소스 그룹 이름
     - `AZURE_LOCATION`: Azure 지역 (예: koreacentral)

#### Azure 서비스 주체 생성
```bash
az ad sp create-for-rbac --name "board-app-sp" --role contributor \
    --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group} \
    --sdk-auth
```

## API 엔드포인트

### 인증
- `POST /api/auth/signup` - 회원가입
- `POST /api/auth/login` - 로그인
- `GET /api/auth/me` - 현재 사용자 정보

### 게시글
- `GET /api/posts` - 게시글 목록 조회
- `GET /api/posts/search` - 게시글 검색
- `GET /api/posts/{id}` - 게시글 상세 조회
- `POST /api/posts` - 게시글 작성
- `PUT /api/posts/{id}` - 게시글 수정
- `DELETE /api/posts/{id}` - 게시글 삭제

## 데이터베이스

- H2 인메모리 데이터베이스 사용
- H2 콘솔: http://localhost:8080/h2-console
- JDBC URL: `jdbc:h2:mem:testdb`
- Username: `sa`
- Password: `password`

## 접속 정보

### 로컬 환경
- Frontend: http://localhost:3000
- Backend API: http://localhost:8080
- H2 Console: http://localhost:8080/h2-console

### Azure 환경
- Frontend: https://{frontend-container}.{location}.azurecontainer.io:3000
- Backend API: https://{backend-container}.{location}.azurecontainer.io:8080
- H2 Console: https://{backend-container}.{location}.azurecontainer.io:8080/h2-console

## 프로젝트 구조

```
project/
├── src/main/java/com/example/demo/
│   ├── config/          # 설정 클래스
│   ├── controller/      # REST API 컨트롤러
│   ├── dto/            # 데이터 전송 객체
│   ├── entity/         # JPA 엔티티
│   ├── repository/     # 데이터 접근 계층
│   ├── security/       # 보안 관련 클래스
│   └── service/        # 비즈니스 로직
├── frontend/
│   ├── src/
│   │   ├── components/ # React 컴포넌트
│   │   ├── contexts/   # React Context
│   │   └── pages/      # 페이지 컴포넌트
│   └── public/         # 정적 파일
├── .github/workflows/  # GitHub Actions CI/CD
├── Dockerfile          # Backend Docker 설정
├── docker-compose.yml  # Docker Compose 설정
├── azure-deploy.sh     # Azure 배포 스크립트
├── azure-config.yml    # Azure 설정 파일
└── build.gradle        # Gradle 설정
```

## 개발 환경 설정

1. Java 17 이상 설치
2. Node.js 18 이상 설치
3. Docker (선택사항)
4. Azure CLI (클라우드 배포 시)

## 배포

### GitHub Actions CI/CD

이 프로젝트는 GitHub Actions를 통한 CI/CD 파이프라인이 설정되어 있습니다.

#### 로컬 배포 (기존)
1. GitHub 저장소에 코드 푸시
2. 자동으로 테스트 및 빌드 실행
3. Docker 이미지 생성 및 로컬 컨테이너 실행

#### Azure 클라우드 배포 (새로운)
1. GitHub 저장소에 코드 푸시
2. 자동으로 테스트 및 빌드 실행
3. Azure Container Registry에 Docker 이미지 푸시
4. Azure Container Instances에 자동 배포
5. 공개 URL로 애플리케이션 접근 가능

### Azure 리소스

배포 시 다음 Azure 리소스가 생성됩니다:
- **리소스 그룹**: `board-app-rg`
- **Azure Container Registry**: `boardappacr`
- **Azure Container Instances**: `board-backend`, `board-frontend`

## 비용 최적화

Azure Container Instances는 사용한 시간만큼만 요금이 부과됩니다:
- Backend: 1 vCPU, 1.5GB 메모리
- Frontend: 0.5 vCPU, 1GB 메모리
- 예상 월 비용: 약 $20-30 (사용량에 따라 변동)

## 라이선스

MIT License 