#!/bin/bash
set -e

SSH_PORT=2222
DEPLOY_USER=deploy
VPS_IP=188.166.125.128

echo "=== 1. Creating deploy user ==="
adduser --disabled-password --gecos "" $DEPLOY_USER
usermod -aG sudo $DEPLOY_USER
echo "$DEPLOY_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$DEPLOY_USER
chmod 440 /etc/sudoers.d/$DEPLOY_USER

mkdir -p /home/$DEPLOY_USER/.ssh
cp /root/.ssh/authorized_keys /home/$DEPLOY_USER/.ssh/
chown -R $DEPLOY_USER:$DEPLOY_USER /home/$DEPLOY_USER/.ssh
chmod 700 /home/$DEPLOY_USER/.ssh
chmod 600 /home/$DEPLOY_USER/.ssh/authorized_keys

echo "=== 2. Installing packages ==="
apt update && apt upgrade -y
apt install -y curl wget git zsh build-essential pkg-config libssl-dev unzip ufw fail2ban docker.io docker-compose

echo "=== 3. SSH hardening ==="
mkdir -p /run/sshd
cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config 2>/dev/null || true
sed -i "s/^Port.*/Port $SSH_PORT/" /etc/ssh/sshd_config
grep -q "^Port $SSH_PORT" /etc/ssh/sshd_config || echo "Port $SSH_PORT" >> /etc/ssh/sshd_config
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sshd -t

echo "=== 4. UFW firewall ==="
ufw allow 22/tcp   # Keep as fallback until 2222 works
ufw allow $SSH_PORT/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw default deny incoming
ufw default allow outgoing
ufw --force enable
systemctl restart ssh
systemctl enable ssh

echo "=== 5. fail2ban + Docker ==="
systemctl enable fail2ban && systemctl start fail2ban
systemctl enable docker && systemctl start docker
usermod -aG docker $DEPLOY_USER

echo "=== 6. Dotfiles + Vermogen ==="
su - $DEPLOY_USER -c "git clone https://github.com/pipa/dotfiles.git ~/dotfiles"
su - $DEPLOY_USER -c "cd ~/dotfiles && ./setup.sh"
su - $DEPLOY_USER -c "git clone git@github.com:LuMatRod/patrimonio.git /opt/patrimonio"

echo "=== DONE ==="
echo "ssh -p $SSH_PORT $DEPLOY_USER@$VPS_IP"
