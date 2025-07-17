#!/bin/bash

# Azure 설정 자동화 스크립트 - CicdTest
# 사용법: ./setup-azure.sh

set -e

echo "🚀 Azure 설정 시작 (CicdTest)..."

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 함수 정의
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Azure CLI 설치 확인
check_azure_cli() {
    print_info "Azure CLI 설치 확인 중..."
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI가 설치되지 않았습니다."
        echo "설치 방법:"
        echo "  Windows: winget install Microsoft.AzureCLI"
        echo "  macOS: brew install azure-cli"
        echo "  Linux: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
        exit 1
    fi
    print_success "Azure CLI가 설치되어 있습니다."
}

# Azure 로그인 확인
check_azure_login() {
    print_info "Azure 로그인 상태 확인 중..."
    if ! az account show &> /dev/null; then
        print_warning "Azure에 로그인되지 않았습니다."
        echo "로그인을 진행합니다..."
        az login
    fi
    print_success "Azure에 로그인되어 있습니다."
}

# 구독 정보 확인
get_subscription_info() {
    print_info "구독 정보 확인 중..."
    SUBSCRIPTION_ID=$(az account show --query id --output tsv)
    SUBSCRIPTION_NAME=$(az account show --query name --output tsv)
    print_success "구독: $SUBSCRIPTION_NAME ($SUBSCRIPTION_ID)"
}

# 리소스 그룹 생성
create_resource_group() {
    print_info "리소스 그룹 생성 중..."
    if az group show --name cicdtest-rg &> /dev/null; then
        print_warning "리소스 그룹 'cicdtest-rg'가 이미 존재합니다."
    else
        az group create \
            --name cicdtest-rg \
            --location koreacentral \
            --tags project=cicdtest environment=production
        print_success "리소스 그룹 'cicdtest-rg'가 생성되었습니다."
    fi
}

# Azure Container Registry 생성
create_acr() {
    print_info "Azure Container Registry 생성 중..."
    if az acr show --name cicdtestacr --resource-group cicdtest-rg &> /dev/null; then
        print_warning "ACR 'cicdtestacr'가 이미 존재합니다."
    else
        az acr create \
            --resource-group cicdtest-rg \
            --name cicdtestacr \
            --sku Basic \
            --admin-enabled true \
            --location koreacentral
        print_success "ACR 'cicdtestacr'가 생성되었습니다."
    fi
}

# ACR 자격 증명 확인
get_acr_credentials() {
    print_info "ACR 자격 증명 확인 중..."
    ACR_USERNAME=$(az acr credential show --name cicdtestacr --query username --output tsv)
    ACR_PASSWORD=$(az acr credential show --name cicdtestacr --query "passwords[0].value" --output tsv)
    print_success "ACR 사용자명: $ACR_USERNAME"
    print_success "ACR 비밀번호: [숨김]"
}

# 서비스 주체 생성
create_service_principal() {
    print_info "서비스 주체 생성 중..."
    
    # 기존 서비스 주체 확인
    if az ad sp list --display-name "cicdtest-sp" --query "[].appId" --output tsv | grep -q .; then
        print_warning "서비스 주체 'cicdtest-sp'가 이미 존재합니다."
        SP_APP_ID=$(az ad sp list --display-name "cicdtest-sp" --query "[0].appId" --output tsv)
    else
        print_info "새로운 서비스 주체를 생성합니다..."
        SP_OUTPUT=$(az ad sp create-for-rbac \
            --name "cicdtest-sp" \
            --role contributor \
            --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/cicdtest-rg \
            --sdk-auth)
        
        # JSON에서 appId 추출
        SP_APP_ID=$(echo $SP_OUTPUT | jq -r '.clientId')
        print_success "서비스 주체가 생성되었습니다. (App ID: $SP_APP_ID)"
    fi
}

# GitHub Secrets 정보 출력
print_github_secrets_info() {
    echo ""
    print_info "=== GitHub Secrets 설정 정보 ==="
    echo ""
    echo "GitHub 저장소 → Settings → Secrets and variables → Actions에서 다음 시크릿을 설정하세요:"
    echo ""
    echo "📋 필수 시크릿:"
    echo ""
    echo "1. AZURE_CREDENTIALS"
    echo "   값: 서비스 주체 생성 시 출력된 JSON 전체"
    echo ""
    echo "2. AZURE_REGISTRY"
    echo "   값: cicdtestacr"
    echo ""
    echo "3. AZURE_REGISTRY_USERNAME"
    echo "   값: $ACR_USERNAME"
    echo ""
    echo "4. AZURE_REGISTRY_PASSWORD"
    echo "   값: $ACR_PASSWORD"
    echo ""
    echo "5. AZURE_RESOURCE_GROUP"
    echo "   값: cicdtest-rg"
    echo ""
    echo "6. AZURE_LOCATION"
    echo "   값: koreacentral"
    echo ""
    print_warning "⚠️  ACR 비밀번호는 보안상 직접 출력하지 않습니다."
    echo "   다음 명령어로 확인하세요:"
    echo "   az acr credential show --name cicdtestacr --query 'passwords[0].value' --output tsv"
    echo ""
}

# 배포 테스트 정보
print_deployment_info() {
    echo ""
    print_info "=== 배포 테스트 정보 ==="
    echo ""
    echo "🚀 배포 테스트 방법:"
    echo ""
    echo "1. GitHub Secrets 설정 완료 후"
    echo "2. GitHub 저장소에 코드 푸시"
    echo "3. Actions 탭에서 워크플로우 진행 상황 확인"
    echo ""
    echo "📊 배포 확인 명령어:"
    echo "   az container list --resource-group cicdtest-rg --output table"
    echo ""
    echo "📝 로그 확인 명령어:"
    echo "   az container logs --resource-group cicdtest-rg --name cicdtest-backend"
    echo "   az container logs --resource-group cicdtest-rg --name cicdtest-frontend"
    echo ""
}

# 메인 실행
main() {
    echo "=========================================="
    echo "  Azure 설정 자동화 - CicdTest"
    echo "=========================================="
    echo ""
    
    check_azure_cli
    check_azure_login
    get_subscription_info
    create_resource_group
    create_acr
    get_acr_credentials
    create_service_principal
    print_github_secrets_info
    print_deployment_info
    
    echo ""
    print_success "Azure 설정이 완료되었습니다! 🎉"
    echo ""
    print_warning "다음 단계: GitHub Secrets 설정 후 코드 푸시"
    echo ""
}

# 스크립트 실행
main "$@" 