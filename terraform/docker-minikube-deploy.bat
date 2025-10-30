@echo off
REM Complete Docker + Minikube Deployment with Terraform (Windows)
REM Builds Docker image and deploys to Minikube using Terraform

setlocal enabledelayedexpansion

echo.
echo ==========================================
echo Docker + Minikube Terraform Deployment
echo ==========================================
echo.

REM Check prerequisites
echo Checking prerequisites...

docker --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker not installed
    exit /b 1
)
echo [OK] Docker installed

minikube version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Minikube not installed
    exit /b 1
)
echo [OK] Minikube installed

kubectl version --client >nul 2>&1
if errorlevel 1 (
    echo ERROR: kubectl not installed
    exit /b 1
)
echo [OK] kubectl installed

terraform --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Terraform not installed
    exit /b 1
)
echo [OK] Terraform installed

REM Start Minikube
echo.
echo Starting Minikube...
call minikube start --cpus=4 --memory=4096 --disk-size=50gb

REM Enable addons
echo.
echo Enabling Minikube addons...
call minikube addons enable registry
call minikube addons enable metrics-server
call minikube addons enable dashboard

REM Configure Docker
echo.
echo Configuring Docker environment...
echo NOTE: For PowerShell, use: minikube docker-env ^| Invoke-Expression
for /f "tokens=*" %%i in ('minikube docker-env --shell cmd') do @@%%i

REM Navigate to terraform
cd terraform

REM Initialize
echo.
echo Initializing Terraform...
call terraform init

REM Format
echo.
echo Formatting Terraform code...
call terraform fmt

REM Validate
echo.
echo Validating Terraform configuration...
call terraform validate

REM Plan
echo.
echo Planning deployment...
call terraform plan -var-file=docker-minikube.tfvars -out=tfplan

REM Ask to continue
echo.
set /p RESPONSE="Review the plan above. Continue? (yes/no): "

if /i not "%RESPONSE%"=="yes" (
    echo Deployment cancelled
    del tfplan
    exit /b 0
)

REM Apply
echo.
echo Applying Terraform configuration...
call terraform apply tfplan

REM Show outputs
echo.
echo ==========================================
echo Deployment Complete!
echo ==========================================
echo.

echo Deployment Information:
call terraform output deployment_status

echo.
echo Next Steps:
echo 1. In a new PowerShell terminal, run:
echo    minikube tunnel
echo.
echo 2. Access your app:
echo    http://localhost
echo.
echo 3. View logs:
echo    kubectl logs -f deployment/react-chatbot -n react-chatbot
echo.
echo 4. Open dashboard:
echo    minikube dashboard
echo.

echo [OK] Deployment ready!
echo.

endlocal
