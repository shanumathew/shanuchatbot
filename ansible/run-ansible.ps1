# Ansible Runner for PowerShell
# Usage: .\ansible\run-ansible.ps1

Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   React Chatbot - Ansible Automation              ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check if Ansible is installed
try {
    python -c "import ansible; print(f'Ansible {ansible.__version__} installed')" 2>$null
    Write-Host "✅ Ansible is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Ansible not found. Install with: pip install ansible" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📋 Available commands:" -ForegroundColor Yellow
Write-Host ""

Write-Host "1. Build Docker image:" -ForegroundColor White
Write-Host "   python -m ansible.cli.playbook -i ansible/inventory.ini ansible/main.yml --tags build" -ForegroundColor Gray

Write-Host ""
Write-Host "2. Tag images for registries:" -ForegroundColor White
Write-Host "   python -m ansible.cli.playbook -i ansible/inventory.ini ansible/main.yml --tags tag" -ForegroundColor Gray

Write-Host ""
Write-Host "3. Push to Azure/AWS:" -ForegroundColor White
Write-Host "   python -m ansible.cli.playbook -i ansible/inventory.ini ansible/main.yml --tags push" -ForegroundColor Gray

Write-Host ""
Write-Host "4. Full pipeline (Build + Tag + Push):" -ForegroundColor White
Write-Host "   python -m ansible.cli.playbook -i ansible/inventory.ini ansible/main.yml" -ForegroundColor Gray

Write-Host ""
Write-Host "5. Manage Azure Container:" -ForegroundColor White
Write-Host "   python -m ansible.cli.playbook -i ansible/inventory.ini ansible/azure-container-manage.yml" -ForegroundColor Gray

Write-Host ""
Write-Host "📚 Documentation:" -ForegroundColor Yellow
Write-Host "   Read: ansible/README.md" -ForegroundColor Gray

Write-Host ""
