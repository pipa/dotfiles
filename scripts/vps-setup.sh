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
apt install -y curl wget git zsh build-essential pkg-config libssl-dev unzip ufw fail2ban ca-certificates gnupg

# Add Docker's official apt repo (docker-compose-plugin lives here, not in Ubuntu's default repos)
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "=== 3. SSH hardening ==="
# Required on some fresh Ubuntu installs — sshd won't restart without it
mkdir -p /run/sshd

# Ensure only one Port line
sed -i '/^Port/d' /etc/ssh/sshd_config
echo "Port $SSH_PORT" >> /etc/ssh/sshd_config

# Harden SSH
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Validate config
sshd -t

# Ubuntu 24 uses socket-activated SSH by default (ssh.socket controls the port).
# Disable the socket unit so sshd_config port takes effect, then enable the service directly.
systemctl disable --now ssh.socket 2>/dev/null || true
systemctl enable ssh
systemctl restart ssh

echo "=== 4. UFW firewall ==="
ufw allow 22/tcp   # Temporary fallback — closed at the end of this script
ufw allow $SSH_PORT/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw default deny incoming
ufw default allow outgoing
ufw --force enable

echo "=== 5. fail2ban + Docker ==="
systemctl enable fail2ban && systemctl start fail2ban
systemctl enable docker && systemctl start docker
usermod -aG docker $DEPLOY_USER

echo "=== 6. Verify SSH on port $SSH_PORT ==="
if ss -tlnp | grep -q ":$SSH_PORT"; then
  echo "SSH is listening on port $SSH_PORT — closing port 22"
  ufw delete allow 22/tcp
  ufw reload
else
  echo "WARNING: SSH does not appear to be listening on port $SSH_PORT"
  echo "Port 22 left open as fallback. Investigate before closing it."
  echo "  ss -tlnp | grep sshd"
fi

echo "=== 7. Install Doppler CLI ==="
curl -Ls https://cli.doppler.com/install.sh | sh

echo "=== 8. Set zsh as default shell for $DEPLOY_USER ==="
chsh -s "$(which zsh)" "$DEPLOY_USER"

echo "=== DONE ==="
echo "Run: doppler login && doppler secrets download ..."
echo "Connect: ssh -p $SSH_PORT $DEPLOY_USER@$VPS_IP"
