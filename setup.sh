#!/bin/bash

# Function to detect Linux distribution
detect_distribution() {
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        case "${ID}" in
            "ubuntu"|"debian")
                pm="apt"
                ;;
            *)
                echo "Unsupported distribution! Only Ubuntu and Debian are supported."
                exit 1
                ;;
        esac
    else
        echo "Cannot detect distribution!"
        exit 1
    fi
}

# Function to install dependencies
install_dependencies() {
    detect_distribution
    $pm update -y
    $pm install -y curl jq apache2-utils
}

# Function to install AdGuard Home as DoH server
install_adguard() {
    if systemctl is-active --quiet AdGuardHome.service; then
        echo "AdGuard Home is already installed and active."
        return
    fi

    install_dependencies

    # Download and install AdGuard Home
    curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v

    # Prompt for domain and admin password
    clear
    read -p "Enter your domain (e.g., yourdomain.com): " domain
    if [ -z "$domain" ]; then
        echo "Domain cannot be empty!"
        exit 1
    fi
    read -p "Enter admin password for AdGuard Home: " password
    if [ -z "$password" ]; then
        echo "Password cannot be empty!"
        exit 1
    fi

    # Install acme.sh for SSL certificates
    curl https://get.acme.sh | sh
    ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
    ~/.acme.sh/acme.sh --issue -d "$domain" --standalone --httpport 80
    ~/.acme.sh/acme.sh --install-cert -d "$domain" \
        --cert-file /opt/AdGuardHome/dnscrypt.crt \
        --key-file /opt/AdGuardHome/dnscrypt.key

    # Set permissions
    chmod 644 /opt/AdGuardHome/dnscrypt.crt
    chmod 600 /opt/AdGuardHome/dnscrypt.key

    # Generate hashed password
    hashed_password=$(htpasswd -bnBC 10 "" "$password" | tr -d ':\n')

    # Configure AdGuard Home for DoH
    cat > /opt/AdGuardHome/AdGuardHome.yaml <<EOL
http:
  address: 0.0.0.0:80
  secure_address: 0.0.0.0:443
  certificate: /opt/AdGuardHome/dnscrypt.crt
  key: /opt/AdGuardHome/dnscrypt.key
dns:
  bind_hosts:
    - 0.0.0.0
  port: 53
  upstream_dns:
    - https://cloudflare-dns.com/dns-query
    - https://dns.google/dns-query
    - https://dns.quad9.net/dns-query
    - https://dns.adguard.com/dns-query
  bootstrap_dns:
    - 8.8.8.8
    - 1.1.1.1
  allow_unencrypted_doh: false
  enable_dnssec: false
  ratelimit: 0
  cache_ttl_min: 0
  cache_ttl_max: 0
users:
  - name: admin
    password: $hashed_password
EOL

    # Enable and start AdGuard Home
    systemctl enable AdGuardHome
    systemctl start AdGuardHome

    # Open firewall ports
    if command -v ufw >/dev/null; then
        ufw allow 53
        ufw allow 80
        ufw allow 443
        ufw allow 7777/udp
        ufw allow 27015/udp
        ufw allow 9000/udp
        ufw reload
    fi

    # Check if AdGuard Home is active
    if systemctl is-active --quiet AdGuardHome.service; then
        echo "AdGuard Home is now active as a DoH server."
        echo "DoH URL: https://$domain/dns-query"
        echo "Web Interface: http://$domain:80 (use admin/$password to log in)"
        echo "Add the DoH URL to Upstream DNS Servers in AdGuard Home on your Iran server."
    else
        echo "Failed to start AdGuard Home. Check logs with: journalctl -u AdGuardHome.service"
        exit 1
    fi
}

# Function to uninstall AdGuard Home
uninstall_adguard() {
    if [ ! -f "/opt/AdGuardHome/AdGuardHome.yaml" ]; then
        echo "AdGuard Home is not installed."
        return
    fi

    # Stop and disable service
    systemctl stop AdGuardHome
    systemctl disable AdGuardHome

    # Remove files
    rm -rf /opt/AdGuardHome
    rm -rf ~/.acme.sh

    # Remove systemd service
    rm -f /etc/systemd/system/AdGuardHome.service
    systemctl daemon-reload

    echo "AdGuard Home uninstalled successfully."
}

# Function to check status
check_status() {
    if systemctl is-active --quiet AdGuardHome.service; then
        echo "[AdGuard Home Service Is Active]"
    else
        echo "[AdGuard Home Service Is Not Active]"
    fi
}

# Main menu
clear
echo "By --> Grok, AdGuard Home DoH Server Setup (Similar to Shecan)"
echo "--*-* DoH DNS Server Installer *-*--"
echo ""
echo "Select an option:"
echo "1) Install AdGuard Home (DoH Server)"
echo "2) Uninstall AdGuard Home"
echo "0) Exit"
echo "----$(check_status)----"
read -p "Enter your choice: " choice

case "$choice" in
    1)
        install_adguard
        ;;
    2)
        uninstall_adguard
        ;;
    0)
        exit
        ;;
    *)
        echo "Invalid choice. Please select a valid option."
        ;;
esac
