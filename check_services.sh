#!/bin/bash
set -e

echo "=== Проверка ключевых служб домашнего облака ==="

# 1 Проверка SSH
if systemctl is-active --quiet ssh; then
    echo "[OK] SSH работает"
else
    echo "[FAIL] SSH не запущен"
fi

# 2 Проверка OpenStack (DevStack) - контроллер
if systemctl is-active --quiet devstack@stack; then
    echo "[OK] DevStack контроллер работает"
else
    echo "[WARN] DevStack сервисы могут быть не запущены"
fi

# Альтернатива: проверка основных OpenStack сервисов
services=("nova-api" "nova-scheduler" "neutron-server" "glance-api" "keystone")
for svc in "${services[@]}"; do
    if systemctl list-units | grep -q "$svc"; then
        echo "[OK] $svc сервис активен"
    else
        echo "[WARN] $svc сервис не найден"
    fi
done

# 3 Проверка Terraform
if command -v terraform &>/dev/null; then
    echo "[OK] Terraform установлен"
else
    echo "[FAIL] Terraform не найден"
fi

# 4 Проверка Ansible
if command -v ansible &>/dev/null; then
    echo "[OK] Ansible установлен"
else
    echo "[FAIL] Ansible не найден"
fi

echo "=== Проверка завершена ==="
