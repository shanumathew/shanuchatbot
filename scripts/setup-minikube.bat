@echo off
REM Minikube Setup Script for Windows
REM Automates local Kubernetes cluster setup and deployment

setlocal enabledelayedexpansion

echo.
echo ==========================================
echo Minikube Setup for React Chatbot
echo ==========================================
echo.

REM Check prerequisites
echo Checking prerequisites...

minikube version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Minikube not installed
    echo Install from: https://github.com/kubernetes/minikube/releases
    exit /b 1
)
echo [OK] Minikube installed

kubectl version --client >nul 2>&1
if errorlevel 1 (
    echo ERROR: kubectl not installed
    echo Install from: https://kubernetes.io/docs/tasks/tools/
    exit /b 1
)
echo [OK] kubectl installed

docker --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker not installed
    echo Install Docker Desktop from: https://www.docker.com/products/docker-desktop
    exit /b 1
)
echo [OK] Docker installed

REM Start Minikube
echo.
echo Starting Minikube...
call minikube start --cpus=4 --memory=4096 --disk-size=50gb
if errorlevel 1 (
    echo ERROR: Failed to start Minikube
    exit /b 1
)
echo [OK] Minikube started

REM Enable addons
echo.
echo Enabling addons...
call minikube addons enable registry
call minikube addons enable metrics-server
call minikube addons enable dashboard
echo [OK] Addons enabled

REM Configure Docker
echo.
echo Configuring Docker...
REM Note: PowerShell users should use: minikube docker-env | Invoke-Expression
echo [OK] Docker configured (run in PowerShell: minikube docker-env ^| Invoke-Expression)

REM Build image
echo.
echo Building Docker image...
REM First set up Docker env
for /f "tokens=*" %%i in ('minikube docker-env --shell cmd') do @@%%i
call docker build -t react-chatbot:latest .
if errorlevel 1 (
    echo ERROR: Failed to build image
    exit /b 1
)
echo [OK] Image built

REM Create namespace
echo.
echo Creating namespace...
call kubectl create namespace react-chatbot
echo [OK] Namespace created

REM Deploy
echo.
echo Deploying to Minikube...
call kubectl apply -f k8s/deployment.yaml -n react-chatbot
if errorlevel 1 (
    echo ERROR: Failed to deploy
    exit /b 1
)
echo [OK] Deployment applied

REM Wait for pods
echo.
echo Waiting for pods to be ready...
call kubectl rollout status deployment/react-chatbot -n react-chatbot --timeout=5m

echo.
echo ==========================================
echo Setup Complete!
echo ==========================================
echo.

echo Cluster Info:
call minikube status
echo.

echo Pods:
call kubectl get pods -n react-chatbot
echo.

echo Services:
call kubectl get svc -n react-chatbot
echo.

echo Next Steps:
echo 1. In a new PowerShell terminal, run: minikube tunnel
echo 2. Access app: http://localhost
echo.

echo Useful commands:
echo   View logs: kubectl logs -f deployment/react-chatbot -n react-chatbot
echo   Dashboard: minikube dashboard
echo   Port forward: kubectl port-forward svc/react-chatbot-service 3000:80 -n react-chatbot
echo   Stop: minikube stop
echo   Delete: minikube delete
echo.

echo [OK] Minikube is ready!
echo.

endlocal
