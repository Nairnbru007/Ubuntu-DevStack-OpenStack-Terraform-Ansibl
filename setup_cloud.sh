#!/bin/bash
set -e

# Подключаем пароли из отдельного файла
source ./secrets.conf

echo "=== 1. Обновление системы и установка зависимостей ==="
sudo apt update && sudo apt upgrade -y
sudo apt install -y git python3-pip curl unzip qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils openssh-server ufw

echo "=== 2. Включение и настройка SSH ==="
sudo systemctl enable --now ssh
sudo ufw allow OpenSSH -y
sudo ufw --force enable
echo "SSH включён и открыт на порту 22"

echo "=== 3. Установка DevStack (OpenStack) ==="
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

echo "=== 4. Установка Terraform ==="
T_VER=$(curl -s https://releases.hashicorp.com/terraform/ | grep -oP 'terraform/\K[0-9\.]+' | head -1)
wget https://releases.hashicorp.com/terraform/${T_VER}/terraform_${T_VER}_linux_amd64.zip -O /tmp/terraform.zip
unzip /tmp/terraform.zip -d /tmp
sudo mv /tmp/terraform /usr/local/bin/
terraform -version

echo "=== 5. Установка Ansible ==="
sudo apt install -y ansible
ansible --version

echo "=== 6. Домашнее облако готово! ==="
echo "OpenStack доступен через веб-интерфейс на $HOST_IP"
echo "SSH доступен на порту 22, используйте его для Ansible"
echo "Теперь можно использовать Terraform и Ansible для создания и настройки VM"
