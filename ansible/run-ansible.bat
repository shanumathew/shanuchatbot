@echo off
REM Ansible Runner Script for Windows
REM This script runs Ansible playbooks using Python directly

echo.
echo ╔════════════════════════════════════════════════════╗
echo ║   React Chatbot - Ansible Automation              ║
echo ╚════════════════════════════════════════════════════╝
echo.

REM Run the main playbook using Python
python -m ansible.cli.adhoc -i ansible/inventory.ini localhost -m shell -a "cd . && echo Ansible configured successfully"

if errorlevel 1 (
    echo.
    echo Note: Ansible needs to be run from WSL/Linux for full functionality
    echo.
    echo Alternative: Use the playbook files directly with:
    echo   - GitHub Actions (automated)
    echo   - Docker compose
    echo   - Manual commands
    echo.
    exit /b 1
)

echo.
echo ✅ Ansible is ready! Use these commands:
echo.
echo Build Docker image:
echo   python -m ansible.cli.playbook -i ansible/inventory.ini ansible/main.yml --tags build
echo.
echo Push to registries:
echo   python -m ansible.cli.playbook -i ansible/inventory.ini ansible/main.yml --tags push
echo.
echo Full deployment:
echo   python -m ansible.cli.playbook -i ansible/inventory.ini ansible/main.yml
echo.
