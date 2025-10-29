@echo off
REM Production Deployment Script - Windows
REM Deploy React Chatbot using Docker Compose

setlocal enabledelayedexpansion

echo.
echo ==========================================
echo React Chatbot - Production Deployment
echo ==========================================
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not installed
    exit /b 1
)

docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker Compose is not installed
    exit /b 1
)

echo Step 1: Building Docker image...
call docker-compose -f docker-compose.prod.yml build
if errorlevel 1 (
    echo ERROR: Build failed
    exit /b 1
)

echo.
echo Step 2: Starting services...
call docker-compose -f docker-compose.prod.yml up -d
if errorlevel 1 (
    echo ERROR: Failed to start services
    exit /b 1
)

echo.
echo Step 3: Verifying deployment...
timeout /t 5 /nobreak

call docker-compose -f docker-compose.prod.yml ps

echo.
echo ==========================================
echo Deployment Successful!
echo ==========================================
echo.

echo Access your app:
echo   http://localhost
echo   https://localhost (if SSL configured)
echo.

echo Useful commands:
echo   View logs: docker-compose -f docker-compose.prod.yml logs -f
echo   Stop: docker-compose -f docker-compose.prod.yml down
echo   Restart: docker-compose -f docker-compose.prod.yml restart
echo   Status: docker-compose -f docker-compose.prod.yml ps
echo.

endlocal
