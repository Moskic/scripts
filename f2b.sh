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
# Get the major version of Debian (e.g., 12)
OS_VER=$(cut -d. -f1 /etc/debian_version)
DEFAULT_NAME="debian${OS_VER}"

# Prompt user for hostname (Interactive)
read -p "Enter new hostname (Press Enter for default: $DEFAULT_NAME): " USER_HOSTNAME
FINAL_NAME=${USER_HOSTNAME:-$DEFAULT_NAME}

echo "Setting hostname to: $FINAL_NAME"
hostnamectl set-hostname "$FINAL_NAME"

# Fix /etc/hosts mapping to prevent sudo resolution errors
if ! grep -qw "$FINAL_NAME" /etc/hosts; then
    echo "127.0.0.1 $FINAL_NAME" >> /etc/hosts
    echo "Host mapping updated in /etc/hosts"
fi

# =========================================================
# 3. Component Installation
# =========================================================
# python3-systemd is required for Fail2Ban to read journald logs on Debian
apt update && apt install -y fail2ban python3-systemd

# =========================================================
# 4. Configuration and Hardening
# =========================================================
# Pre-create log file to prevent recidive jail from failing on first start
touch /var/log/fail2ban.log

# Write Fail2Ban configuration
# [sshd]: Basic protection (3 retries, 1h ban)
# [recidive]: Permanent ban for repeat offenders (5 bans in 1 day = Permanent)
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
systemctl restart fail2ban

echo "========================================"
echo "Configuration Completed Successfully"
echo "Hostname set to: $FINAL_NAME"
echo "Fail2Ban Protection: Active"
echo "========================================"

# Display active jails
fail2ban-client status sshd
fail2ban-client status recidive
