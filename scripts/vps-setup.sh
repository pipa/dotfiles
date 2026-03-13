#!/bin/bash
set -e

SSH_PORT=2222
DEPLOY_USER=deploy
VPS_IP=188.166.125.128

# ═══════════════════════════════════════════
# Bail if not root (early, before TUI loads)
# ═══════════════════════════════════════════
if [[ $EUID -ne 0 ]]; then
    echo "Run as root: sudo bash vps-setup.sh"
    exit 1
fi

# ═══════════════════════════════════════════
# Project prompt (before animation starts)
# ═══════════════════════════════════════════
clear
echo ""
printf "\033[36m"
printf "      ▄▄   ▄▄     \n"
printf "     ▐████████▌    \n"
printf "    ▐██▀▄▄▄▀██▌    \n"
printf "   ▗████   ████▖   \n"
printf "   ▐▘ ▝▀███▀▝ ▝▌   \n"
printf "       ▌   ▌       \n"
printf "\033[0m"
echo ""
printf "  \033[1mvps-setup\033[0m  \033[2m—  server bootstrap\033[0m\n"
echo ""

read -rp "  Project name (e.g. patrimonio): " PROJECT_NAME
read -rp "  GitHub repo (e.g. LuMatRod/patrimonio): " GITHUB_REPO

PROJECT_DIR="/opt/${PROJECT_NAME}"

echo ""

# ═══════════════════════════════════════════
# TUI — bouncing progress bar (ported from setup.sh)
# ═══════════════════════════════════════════
BAR_WIDTH=30
BLOCK_LEN=4
DIM="\033[2m"
BOLD="\033[1m"
CYAN="\033[36m"
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
RESET="\033[0m"

LOG_FILE="/tmp/vps-setup-$$.log"
STEP_FILE="/tmp/vps-setup-step-$$"
ANIM_PID=""
RESULTS=()
FAILED=false

start_animation() {
    echo "" > "$STEP_FILE"
    (
        local pos=0 dir=1
        local max=$((BAR_WIDTH - BLOCK_LEN))
        tput civis 2>/dev/null
        while true; do
            local msg bar=""
            msg=$(cat "$STEP_FILE" 2>/dev/null)
            for ((i = 0; i < BAR_WIDTH; i++)); do
                if ((i >= pos && i < pos + BLOCK_LEN)); then
                    bar+="█"
                else
                    bar+="░"
                fi
            done
            printf "\r  ${DIM}${CYAN}%s${RESET}  ${BOLD}%s${RESET}" "$bar" "$msg"
            printf "%-10s" ""
            pos=$((pos + dir))
            if ((pos >= max)); then dir=-1; fi
            if ((pos <= 0)); then dir=1; fi
            sleep 0.04
        done
    ) &
    ANIM_PID=$!
}

stop_animation() {
    if [[ -n "$ANIM_PID" ]]; then
        kill "$ANIM_PID" 2>/dev/null
        wait "$ANIM_PID" 2>/dev/null || true
        ANIM_PID=""
    fi
    tput cnorm 2>/dev/null
    printf "\r%-80s\r" ""
}

set_step() {
    echo "$1" > "$STEP_FILE"
}

run_step() {
    local label="$1"
    shift
    set_step "$label"
    echo "=== $label ===" >> "$LOG_FILE"
    if "$@" >> "$LOG_FILE" 2>&1; then
        RESULTS+=("${GREEN}✓${RESET} $label")
        return 0
    else
        local exit_code=$?
        RESULTS+=("${RED}✗${RESET} $label")
        stop_animation
        echo ""
        printf "  ${RED}${BOLD}Error:${RESET} %s failed (exit %d)\n" "$label" "$exit_code"
        echo ""
        printf "  ${DIM}Last 10 lines of output:${RESET}\n"
        tail -10 "$LOG_FILE" | while IFS= read -r line; do
            printf "  ${DIM}│${RESET} %s\n" "$line"
        done
        echo ""
        printf "  ${DIM}Full log: %s${RESET}\n" "$LOG_FILE"
        echo ""
        FAILED=true
        start_animation
        return 1
    fi
}

: > "$LOG_FILE"

start_animation

# ═══════════════════════════════════════════
# 1. Deploy user
# ═══════════════════════════════════════════
setup_deploy_user() {
    adduser --disabled-password --gecos "" $DEPLOY_USER
    usermod -aG sudo $DEPLOY_USER
    echo "$DEPLOY_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$DEPLOY_USER
    chmod 440 /etc/sudoers.d/$DEPLOY_USER
    mkdir -p /home/$DEPLOY_USER/.ssh
    if [ -f /root/.ssh/authorized_keys ]; then
        cp /root/.ssh/authorized_keys /home/$DEPLOY_USER/.ssh/
    fi
    chown -R $DEPLOY_USER:$DEPLOY_USER /home/$DEPLOY_USER/.ssh
    chmod 700 /home/$DEPLOY_USER/.ssh
    chmod 600 /home/$DEPLOY_USER/.ssh/authorized_keys 2>/dev/null || true
}

if id "$DEPLOY_USER" &>/dev/null; then
    RESULTS+=("${GREEN}✓${RESET} Deploy user ${DIM}(already exists)${RESET}")
else
    run_step "Creating deploy user" setup_deploy_user
fi

# ═══════════════════════════════════════════
# 2. Packages + Docker
# ═══════════════════════════════════════════
install_packages() {
    apt update && apt upgrade -y
    apt install -y curl wget git zsh build-essential pkg-config libssl-dev unzip ufw fail2ban ca-certificates gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
        | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
}

run_step "Installing packages + Docker" install_packages

# ═══════════════════════════════════════════
# 3. SSH hardening
# ═══════════════════════════════════════════
harden_ssh() {
    mkdir -p /run/sshd
    sed -i '/^Port/d' /etc/ssh/sshd_config
    echo "Port $SSH_PORT" >> /etc/ssh/sshd_config
    sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    sshd -t
    systemctl disable --now ssh.socket 2>/dev/null || true
    systemctl enable ssh
    systemctl restart ssh
}

run_step "Hardening SSH (port $SSH_PORT)" harden_ssh

# ═══════════════════════════════════════════
# 4. Firewall
# ═══════════════════════════════════════════
setup_firewall() {
    ufw allow 22/tcp
    ufw allow $SSH_PORT/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw default deny incoming
    ufw default allow outgoing
    ufw --force enable
    if ss -tlnp | grep -q ":$SSH_PORT"; then
        ufw delete allow 22/tcp
        ufw reload
    fi
}

run_step "Configuring UFW firewall" setup_firewall

# ═══════════════════════════════════════════
# 5. Services
# ═══════════════════════════════════════════
setup_services() {
    systemctl enable fail2ban && systemctl start fail2ban
    systemctl enable docker && systemctl start docker
    usermod -aG docker $DEPLOY_USER
}

run_step "Starting fail2ban + Docker" setup_services

# ═══════════════════════════════════════════
# 6. Doppler CLI
# ═══════════════════════════════════════════
if command -v doppler &>/dev/null; then
    RESULTS+=("${GREEN}✓${RESET} Doppler CLI ${DIM}(already installed)${RESET}")
else
    run_step "Installing Doppler CLI" sh -c "curl -Ls https://cli.doppler.com/install.sh | sh"
fi

# ═══════════════════════════════════════════
# 7. Project directory
# ═══════════════════════════════════════════
setup_project_dir() {
    mkdir -p "$PROJECT_DIR"
    chown "$DEPLOY_USER:$DEPLOY_USER" "$PROJECT_DIR"
}

if [[ -d "$PROJECT_DIR" ]]; then
    RESULTS+=("${GREEN}✓${RESET} Project dir ${DIM}($PROJECT_DIR already exists)${RESET}")
else
    run_step "Creating $PROJECT_DIR" setup_project_dir
fi

# ═══════════════════════════════════════════
# 8. Deploy SSH key
# ═══════════════════════════════════════════
DEPLOY_KEY_PATH="/home/$DEPLOY_USER/.ssh/github_deploy"

generate_deploy_key() {
    sudo -u "$DEPLOY_USER" ssh-keygen -t ed25519 -C "deploy@vps" -f "$DEPLOY_KEY_PATH" -N ""
    # Ensure .ssh dir and authorized_keys exist with correct permissions
    mkdir -p "/home/$DEPLOY_USER/.ssh"
    touch "/home/$DEPLOY_USER/.ssh/authorized_keys"
    chmod 700 "/home/$DEPLOY_USER/.ssh"
    chmod 600 "/home/$DEPLOY_USER/.ssh/authorized_keys"
    chown -R "$DEPLOY_USER:$DEPLOY_USER" "/home/$DEPLOY_USER/.ssh"
    # Add public key so GitHub Actions can SSH in with this key
    cat "${DEPLOY_KEY_PATH}.pub" >> "/home/$DEPLOY_USER/.ssh/authorized_keys"
    # Configure SSH to use it for GitHub
    sudo -u "$DEPLOY_USER" bash -c "cat >> ~/.ssh/config << 'EOF'
Host github.com
  IdentityFile ~/.ssh/github_deploy
  StrictHostKeyChecking accept-new
EOF"
}

if [[ -f "$DEPLOY_KEY_PATH" ]]; then
    RESULTS+=("${GREEN}✓${RESET} Deploy SSH key ${DIM}(already exists)${RESET}")
else
    run_step "Generating deploy SSH key" generate_deploy_key
fi

# ═══════════════════════════════════════════
# 9. zsh as default shell for deploy
# ═══════════════════════════════════════════
run_step "Setting zsh as default shell for $DEPLOY_USER" chsh -s "$(which zsh)" "$DEPLOY_USER"

# ═══════════════════════════════════════════
# Done
# ═══════════════════════════════════════════
stop_animation

echo ""
if $FAILED; then
    printf "  ${BOLD}${YELLOW}Setup completed with errors${RESET}\n"
else
    printf "  ${BOLD}${GREEN}Setup complete${RESET}\n"
fi
echo ""

for result in "${RESULTS[@]}"; do
    printf "  %b\n" "$result"
done

echo ""
printf "  ${DIM}───────────────────────────────────────${RESET}\n"
echo ""
printf "  ${BOLD}Next steps:${RESET}\n"
echo ""
printf "  ${DIM}1.${RESET} SSH in as deploy:\n"
printf "     ${BOLD}ssh -p $SSH_PORT $DEPLOY_USER@$VPS_IP${RESET}\n"
echo ""
printf "  ${DIM}2.${RESET} Add the deploy public key to GitHub in two places:\n"
echo ""
printf "     ${BOLD}A) github.com/${GITHUB_REPO} → Settings → Deploy keys${RESET} (read-only)\n"
printf "     ${BOLD}B) github.com/${GITHUB_REPO} → Settings → Secrets → DEPLOY_SSH_KEY${RESET} (paste the private key below)\n"
echo ""
printf "     ${CYAN}${BOLD}Public key:${RESET}\n"
if [[ -f "${DEPLOY_KEY_PATH}.pub" ]]; then
    printf "     %s\n" "$(cat "${DEPLOY_KEY_PATH}.pub")"
else
    printf "     ${RED}(key not found at ${DEPLOY_KEY_PATH}.pub)${RESET}\n"
fi
echo ""
printf "     ${CYAN}${BOLD}Private key (for DEPLOY_SSH_KEY secret):${RESET}\n"
if [[ -f "$DEPLOY_KEY_PATH" ]]; then
    cat "$DEPLOY_KEY_PATH"
else
    printf "     ${RED}(key not found at ${DEPLOY_KEY_PATH})${RESET}\n"
fi
echo ""
printf "  ${DIM}3.${RESET} Clone the repo (dir already created at $PROJECT_DIR):\n"
printf "     ${BOLD}git clone git@github.com:${GITHUB_REPO}.git ${PROJECT_DIR}${RESET}\n"
echo ""
printf "  ${DIM}4.${RESET} Pull secrets from Doppler (run as $DEPLOY_USER):\n"
printf "     ${BOLD}doppler login${RESET}\n"
printf "     ${BOLD}cd ${PROJECT_DIR} && doppler secrets download --no-file --format env --project ${PROJECT_NAME} --config prd > .env${RESET}\n"
printf "     ${BOLD}chmod 600 .env${RESET}\n"
echo ""
printf "  ${DIM}5.${RESET} First deploy:\n"
printf "     ${BOLD}cd ${PROJECT_DIR}${RESET}\n"
printf "     ${BOLD}docker compose build --no-cache web${RESET}\n"
printf "     ${BOLD}docker compose up -d${RESET}\n"
printf "     ${BOLD}docker compose --profile migrate run --rm migrate${RESET}\n"
echo ""
printf "  ${DIM}6.${RESET} Update GitHub Actions secrets:\n"
printf "     ${DIM}DEPLOY_HOST${RESET}    → $VPS_IP\n"
printf "     ${DIM}DEPLOY_USER${RESET}    → $DEPLOY_USER\n"
printf "     ${DIM}DEPLOY_SSH_KEY${RESET} → contents of ~/.ssh/github_deploy\n"
printf "     ${DIM}DEPLOY_DOMAIN${RESET}  → your domain\n"
echo ""

rm -f "$STEP_FILE"
