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

# Copy authorized_keys if they exist
if [ -f /root/.ssh/authorized_keys ]; then
  cp /root/.ssh/authorized_keys /home/$DEPLOY_USER/.ssh/
else
  echo "WARNING: /root/.ssh/authorized_keys not found — deploy user has no SSH keys!"
fi

chown -R $DEPLOY_USER:$DEPLOY_USER /home/$DEPLOY_USER/.ssh
chmod 700 /home/$DEPLOY_USER/.ssh
chmod 600 /home/$DEPLOY_USER/.ssh/authorized_keys 2>/dev/null || true

echo "=== 2. Installing packages ==="
apt update && apt upgrade -y
# Note: docker-compose (v1) is removed in Ubuntu 24. Use docker-compose-plugin (v2).
apt install -y curl wget git zsh build-essential pkg-config libssl-dev unzip ufw fail2ban docker.io docker-compose-plugin

echo "=== 3. SSH hardening ==="
# Ensure only one Port line
sed -i '/^Port/d' /etc/ssh/sshd_config
echo "Port $SSH_PORT" >> /etc/ssh/sshd_config

# Harden SSH
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Validate config then restart via systemd (do NOT kill sshd manually — you'll drop your connection)
sshd -t
systemctl restart ssh

echo "=== 4. UFW firewall ==="
ufw allow 22/tcp   # Keep as fallback until 2222 works
ufw allow $SSH_PORT/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw default deny incoming
ufw default allow outgoing
ufw --force enable

systemctl enable ssh

echo "=== 5. fail2ban + Docker ==="
systemctl enable fail2ban && systemctl start fail2ban
systemctl enable docker && systemctl start docker
usermod -aG docker $DEPLOY_USER

echo "=== 6. Clone Vermogen ==="
# NOTE: This uses HTTPS to avoid needing an SSH key for the deploy user at setup time.
# If the repo is private, you'll need a Personal Access Token:
#   git clone https://<token>@github.com/LuMatRod/patrimonio.git /opt/patrimonio
su - $DEPLOY_USER -c "git clone https://github.com/LuMatRod/patrimonio.git /opt/patrimonio"

echo "=== DONE ==="
echo "SSH on port $SSH_PORT"
echo "Connect: ssh -p $SSH_PORT $DEPLOY_USER@$VPS_IP"
echo ""
echo "After confirming $SSH_PORT works, close port 22:"
echo "  ufw delete allow 22/tcp"
