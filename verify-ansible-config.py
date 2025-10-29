#!/usr/bin/env python3
"""Ansible Configuration Verification Script"""

import os
import yaml
import sys

def main():
    print("\n" + "="*60)
    print("ANSIBLE CONFIGURATION VERIFICATION")
    print("="*60)

    errors = 0

    # Check Ansible installation
    try:
        import ansible
        print(f"\n[✓] Ansible {ansible.__version__} is installed")
    except ImportError:
        print("\n[✗] Ansible not installed")
        errors += 1

    # Check inventory file
    if os.path.exists('ansible/inventory.ini'):
        print("[✓] Inventory file exists: ansible/inventory.ini")
    else:
        print("[✗] Inventory file not found")
        errors += 1

    # Check playbooks
    playbooks = [
        'ansible/main.yml',
        'ansible/docker-build-push.yml',
        'ansible/azure-container-manage.yml'
    ]

    for playbook in playbooks:
        if os.path.exists(playbook):
            try:
                with open(playbook, encoding='utf-8') as f:
                    yaml.safe_load(f)
                print(f"[✓] {playbook} - valid YAML")
            except Exception as e:
                print(f"[✗] {playbook} - YAML Error: {str(e)[:40]}")
                errors += 1
        else:
            print(f"[✗] {playbook} - file not found")
            errors += 1

    # Check Docker
    try:
        import subprocess
        subprocess.run(['docker', '--version'], capture_output=True, check=True)
        print("[✓] Docker is installed and accessible")
    except:
        print("[⚠] Docker not verified (may need to be in PATH)")

    # Verify configuration values
    print("\n" + "="*60)
    print("CONFIGURATION VALUES")
    print("="*60)

    try:
        with open('ansible/inventory.ini', encoding='utf-8') as f:
            content = f.read()
            
        configs = {
            'Azure Registry': 'azure_registry=shanumathew',
            'AWS ECR Account': 'aws_ecr_account=317009750119',
            'Docker Image': 'docker_image=react-chatbot:latest',
            'Container Port': 'azure_port=3000',
        }
        
        for name, key in configs.items():
            if key in content:
                print(f"[✓] {name} - configured")
            else:
                print(f"[✗] {name} - NOT found")
                errors += 1
                
    except Exception as e:
        print(f"[✗] Error reading configuration: {e}")
        errors += 1

    # Summary
    print("\n" + "="*60)
    if errors == 0:
        print("STATUS: ALL CONFIGURATIONS VERIFIED ✓")
        print("="*60)
        print("\nAnsible is ready to use!")
        print("\nQuick commands:")
        print("  Build:  python -m ansible.cli.playbook -i ansible/inventory.ini ansible/main.yml --tags build")
        print("  Push:   python -m ansible.cli.playbook -i ansible/inventory.ini ansible/main.yml --tags push")
        print("  Full:   python -m ansible.cli.playbook -i ansible/inventory.ini ansible/main.yml")
        print("\n")
        return 0
    else:
        print(f"STATUS: {errors} ERROR(S) FOUND ✗")
        print("="*60 + "\n")
        return 1

if __name__ == '__main__':
    sys.exit(main())
