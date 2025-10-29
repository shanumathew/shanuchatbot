@echo off
REM Terraform deployment script for Render (Windows)
REM Automates GitHub setup and provides Render deployment instructions

setlocal enabledelayedexpansion

echo.
echo ==========================================
echo Render Deployment - Terraform Setup
echo ==========================================
echo.

REM Check Terraform
echo Checking Terraform...
terraform --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Terraform not installed
    exit /b 1
)

REM Navigate to terraform
cd terraform

REM Check render.tfvars
if not exist render.tfvars (
    echo Creating render.tfvars from example...
    copy render.tfvars.example render.tfvars
    echo Please edit render.tfvars with your GitHub token
    echo Get token from: https://github.com/settings/tokens
    exit /b 1
)

REM Initialize
echo.
echo Initializing Terraform...
call terraform init

REM Validate
echo.
echo Validating configuration...
call terraform validate

REM Plan
echo.
echo Planning deployment...
call terraform plan -var-file=render.tfvars -out=tfplan

REM Apply
echo.
echo Applying configuration...
call terraform apply tfplan

echo.
echo ==========================================
echo Setup Complete!
echo ==========================================
echo.

echo Next Steps:
echo.
echo 1. Push code to GitHub:
echo    cd ..
echo    git add .
echo    git commit -m "Configure for Render"
echo    git push origin master
echo.
echo 2. Go to https://render.com/
echo 3. Sign in with GitHub
echo 4. Click "New +" - "Web Service"
echo 5. Select your repository
echo 6. Configure and deploy
echo.
echo [OK] Terraform setup complete!
echo.

endlocal
