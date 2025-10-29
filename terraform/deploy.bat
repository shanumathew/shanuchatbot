@echo off
REM Terraform Setup and Deployment Script for Windows
REM This script initializes and applies Terraform configuration

setlocal enabledelayedexpansion

echo.
echo ==========================================
echo Terraform Setup for React Chatbot
echo ==========================================
echo.

REM Check if Terraform is installed
echo Checking Terraform installation...
terraform --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Terraform is not installed. Please install it first.
    echo Download from: https://www.terraform.io/downloads.html
    exit /b 1
)
echo [OK] Terraform installed

REM Check if Azure CLI is installed
echo Checking Azure CLI installation...
az --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Azure CLI is not installed. Please install it first.
    echo Install: pip install azure-cli
    exit /b 1
)
echo [OK] Azure CLI installed

REM Check if logged in to Azure
echo Checking Azure login status...
az account show >nul 2>&1
if errorlevel 1 (
    echo Not logged in to Azure. Please log in...
    call az login
    if errorlevel 1 (
        echo ERROR: Failed to login to Azure
        exit /b 1
    )
)

for /f "delims=" %%i in ('az account show --query name -o tsv') do set SUBSCRIPTION=%%i
echo [OK] Logged in as: %SUBSCRIPTION%

REM Navigate to terraform directory
cd terraform

REM Check if terraform.tfvars exists
if not exist terraform.tfvars (
    echo terraform.tfvars not found. Creating from example...
    copy terraform.tfvars.example terraform.tfvars
    echo Please edit terraform.tfvars and add your Subscription ID
    echo Get ID by running: az account show --query id -o tsv
    exit /b 1
)

REM Initialize Terraform
echo.
echo Initializing Terraform...
call terraform init
if errorlevel 1 (
    echo ERROR: Terraform init failed
    exit /b 1
)
echo [OK] Terraform initialized

REM Validate configuration
echo.
echo Validating configuration...
call terraform validate
if errorlevel 1 (
    echo ERROR: Terraform validation failed
    exit /b 1
)
echo [OK] Configuration valid

REM Format files
echo.
echo Formatting Terraform files...
call terraform fmt >nul 2>&1
echo [OK] Files formatted

REM Plan deployment
echo.
echo Planning deployment...
call terraform plan -out=tfplan
if errorlevel 1 (
    echo ERROR: Terraform plan failed
    exit /b 1
)

REM Ask for confirmation
echo.
echo Review the plan above. Do you want to proceed? (yes/no)
set /p CONFIRM="Enter choice: "

if /i not "%CONFIRM%"=="yes" (
    echo Deployment cancelled.
    exit /b 0
)

REM Apply configuration
echo.
echo Applying Terraform configuration...
call terraform apply tfplan
if errorlevel 1 (
    echo ERROR: Terraform apply failed
    exit /b 1
)

REM Show outputs
echo.
echo ==========================================
echo Deployment Complete!
echo ==========================================
echo.

echo Key Outputs:
call terraform output
echo.

echo Next Steps:
echo 1. Build Docker image:
echo    docker build -t react-chatbot:latest ..
echo.
echo 2. Push to ACR:
for /f "delims=" %%i in ('terraform output -raw acr_login_server') do (
    echo    docker tag react-chatbot:latest %%i/react-chatbot:latest
    echo    docker push %%i/react-chatbot:latest
)
echo.
echo 3. Deploy to AKS (if using):
echo    az aks get-credentials --resource-group react-chatbot-rg --name react-chatbot-aks
echo    kubectl apply -f ../k8s/deployment.yaml
echo.
echo 4. Access App Service (if using):
for /f "delims=" %%i in ('terraform output -raw app_service_url') do echo    %%i
echo.

echo [OK] Infrastructure deployed successfully!
echo.

endlocal
