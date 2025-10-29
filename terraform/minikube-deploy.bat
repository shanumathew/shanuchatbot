@echo off
REM Minikube Terraform Deployment (Windows)
REM Deploy to local Minikube cluster using Terraform

setlocal enabledelayedexpansion

echo.
echo ==========================================
echo Minikube Terraform Deployment
echo ==========================================
echo.

REM Check prerequisites
echo Checking prerequisites...

minikube version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Minikube not installed
    exit /b 1
)

kubectl version --client >nul 2>&1
if errorlevel 1 (
    echo ERROR: kubectl not installed
    exit /b 1
)

terraform --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Terraform not installed
    exit /b 1
)

echo [OK] All prerequisites met
echo.

REM Start Minikube
echo Starting Minikube...
call minikube start --cpus=4 --memory=4096

REM Build Docker image
echo.
echo Building Docker image...
for /f "tokens=*" %%i in ('minikube docker-env --shell cmd') do @@%%i
call docker build -t react-chatbot:latest .

REM Navigate to terraform
cd terraform

REM Initialize
echo.
echo Initializing Terraform...
call terraform init

REM Plan
echo.
echo Planning deployment...
call terraform plan -var-file=minikube.tfvars -out=tfplan

REM Apply
echo.
echo Applying configuration...
call terraform apply tfplan

echo.
echo ==========================================
echo Deployment Complete!
echo ==========================================
echo.

echo Next Steps:
echo.
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

echo [OK] Minikube deployment ready!
echo.

endlocal
