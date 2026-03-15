#!/bin/bash
set -e

# Подключаем пароли из отдельного файла
source ./secrets.conf

echo "=== 1. Обновление системы и установка зависимостей ==="
sudo apt update && sudo apt upgrade -y
sudo apt install -y git python3-pip curl unzip qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils

echo "=== 2. Установка DevStack (OpenStack) ==="
if [ ! -d ~/devstack ]; then
  git clone https://opendev.org/openstack/devstack.git ~/devstack
fi
cd ~/devstack

cat > local.conf <<EOL
[[local|localrc]]
ADMIN_PASSWORD=$ADMIN_PASSWORD
DATABASE_PASSWORD=$DATABASE_PASSWORD
RABBIT_PASSWORD=$RABBIT_PASSWORD
SERVICE_PASSWORD=$SERVICE_PASSWORD
HOST_IP=$HOST_IP
EOL

echo "=== Запуск DevStack (может занять 15-30 минут) ==="
./stack.sh

echo "=== 3. Установка Terraform ==="
T_VER=$(curl -s https://releases.hashicorp.com/terraform/ | grep -oP 'terraform/\K[0-9\.]+' | head -1)
wget https://releases.hashicorp.com/terraform/${T_VER}/terraform_${T_VER}_linux_amd64.zip -O /tmp/terraform.zip
unzip /tmp/terraform.zip -d /tmp
sudo mv /tmp/terraform /usr/local/bin/
terraform -version

echo "=== 4. Установка Ansible ==="
sudo apt install -y ansible
ansible --version

echo "=== 5. Домашнее облако готово! ==="
echo "OpenStack доступен через веб-интерфейс на $HOST_IP"
echo "Используйте Terraform и Ansible для создания и настройки VM"
