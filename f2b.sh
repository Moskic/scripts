#!/bin/bash

# =========================================================
# One-click security script for Debian 11-13: 
# SSH hardening, hostname customization, and permanent banning of repeat offenders.
#
#1. Root Privilege Check
# =========================================================
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root!"
   exit 1
fi

# =========================================================
# 2. Hostname Configuration
# =========================================================
OS_VER=$(cut -d. -f1 /etc/debian_version)
DEFAULT_NAME="debian${OS_VER}"

# FIX 1: Use < /dev/tty to force interactive input during pipe execution
echo "Please set your hostname."
read -p "Enter new hostname (Press Enter for default: $DEFAULT_NAME): " USER_HOSTNAME < /dev/tty
FINAL_NAME=${USER_HOSTNAME:-$DEFAULT_NAME}

echo "Setting hostname to: $FINAL_NAME"
hostnamectl set-hostname "$FINAL_NAME"

if ! grep -qw "$FINAL_NAME" /etc/hosts; then
    echo "127.0.0.1 $FINAL_NAME" >> /etc/hosts
    echo "Host mapping updated in /etc/hosts"
fi

# =========================================================
# 3. Component Installation
# =========================================================
apt update && apt install -y fail2ban python3-systemd

# =========================================================
# 4. Configuration and Hardening
# =========================================================
touch /var/log/fail2ban.log

cat << EOC > /etc/fail2ban/jail.local
[DEFAULT]
backend = systemd
bantime  = 1h
findtime  = 10m
maxretry = 3
ignoreip = 127.0.0.1/8 ::1

[sshd]
enabled = true

[recidive]
enabled = true
logpath  = /var/log/fail2ban.log
filter   = recidive
bantime  = -1
findtime = 1d
maxretry = 5
EOC

# =========================================================
# 5. Service Activation and Status
# =========================================================
# Ensure service is enabled to start on boot
systemctl enable fail2ban
systemctl restart fail2ban

# FIX 2: Wait for 3 seconds to ensure the socket file is created
echo "Waiting for Fail2Ban service to initialize..."
sleep 3

echo "========================================"
echo "Configuration Completed Successfully"
echo "Hostname set to: $FINAL_NAME"
echo "Fail2Ban Protection: Active"
echo "========================================"

# Display active jails (using --no-pager to avoid getting stuck)
fail2ban-client status sshd
fail2ban-client status recidive
