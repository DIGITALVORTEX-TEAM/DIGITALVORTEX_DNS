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
    $pm install -y curl jq socat
}

# Function to install dnsproxy as DoH server
install_dnsproxy() {
    if systemctl is-active --quiet dnsproxy.service; then
        echo "dnsproxy is already installed and active."
        return
    fi

    install_dependencies

    # Download and install dnsproxy
    LATEST_RELEASE=$(curl -s https://api.github.com/repos/AdguardTeam/dnsproxy/releases/latest | jq -r '.tag_name')
    curl -sL "https://github.com/AdguardTeam/dnsproxy/releases/download/${LATEST_RELEASE}/dnsproxy-linux-amd64-${LATEST_RELEASE}.tar.gz" -o dnsproxy.tar.gz
    tar -xzf dnsproxy.tar.gz
    sudo mv linux-amd64/dnsproxy /usr/local/bin/dnsproxy
    rm -rf linux-amd64 dnsproxy.tar.gz

    # Set domain
    domain="smartsni.aryaline.ir"

    # Install acme.sh for SSL certificates
    curl https://get.acme.sh | sh
    ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt

    # Stop any service using port 80
    sudo systemctl stop dnsproxy 2>/dev/null || true
    sudo fuser -k 80/tcp 2>/dev/null || true

    # Issue SSL certificate
    ~/.acme.sh/acme.sh --issue -d "$domain" --standalone --httpport 80 --force
    if [ $? -ne 0 ]; then
        echo "Failed to issue SSL certificate. Check if the domain points to this server's IP and port 80 is free."
        exit 1
    fi

    # Install SSL certificate
    ~/.acme.sh/acme.sh --install-cert -d "$domain" \
        --cert-file /etc/dnsproxy/dnscrypt.crt \
        --key-file /etc/dnsproxy/dnscrypt.key

    # Set permissions
    sudo mkdir -p /etc/dnsproxy
    sudo chmod 644 /etc/dnsproxy/dnscrypt.crt
    sudo chmod 600 /etc/dnsproxy/dnscrypt.key

    # Verify certificate files exist
    if [ ! -f /etc/dnsproxy/dnscrypt.crt ] || [ ! -f /etc/dnsproxy/dnscrypt.key ]; then
        echo "SSL certificate files were not created. Please check acme.sh logs."
        exit 1
    fi

    # Create dnsproxy configuration
    cat > /etc/dnsproxy/config.yaml <<EOL
listen-addr: 0.0.0.0
listen-port: 53
https-listen-port: 443
certificate-path: /etc/dnsproxy/dnscrypt.crt
private-key-path: /etc/dnsproxy/dnscrypt.key
upstream:
  - https://cloudflare-dns.com/dns-query
  - https://dns.google/dns-query
  - https://dns.quad9.net/dns-query
bootstrap:
  - 8.8.8.8
  - 1.1.1.1
EOL

    # Create systemd service for dnsproxy
    cat > /etc/systemd/system/dnsproxy.service <<EOL
[Unit]
Description=dnsproxy DoH Server
After=network.target

[Service]
ExecStart=/usr/local/bin/dnsproxy -c /etc/dnsproxy/config.yaml
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOL

    # Enable and start dnsproxy
    sudo systemctl daemon-reload
    sudo systemctl enable dnsproxy
    sudo systemctl start dnsproxy

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

    # Check if dnsproxy is active
    if systemctl is-active --quiet dnsproxy.service; then
        echo "dnsproxy is now active as a DoH server."
        echo "DoH URL: https://$domain/dns-query"
        echo "Add the DoH URL to Upstream DNS Servers in AdGuard Home on your Iran server."
    else
        echo "Failed to start dnsproxy. Check logs with: journalctl -u dnsproxy.service"
        exit 1
    fi
}

# Function to uninstall dnsproxy
uninstall_dnsproxy() {
    if [ ! -f "/etc/dnsproxy/config.yaml" ]; then
        echo "dnsproxy is not installed."
        return
    fi

    # Stop and disable service
    sudo systemctl stop dnsproxy
    sudo systemctl disable dnsproxy

    # Remove files
    sudo rm -rf /etc/dnsproxy
    sudo rm -rf /usr/local/bin/dnsproxy
    sudo rm -rf ~/.acme.sh

    # Remove systemd service
    sudo rm -f /etc/systemd/system/dnsproxy.service
    sudo systemctl daemon-reload

    echo "dnsproxy uninstalled successfully."
}

# Function to check status
check_status() {
    if systemctl is-active --quiet dnsproxy.service; then
        echo "[dnsproxy Service Is Active]"
    else
        echo "[dnsproxy Service Is Not Active]"
    fi
}

# Main menu
clear
echo "By --> Grok, dnsproxy DoH Server Setup (Similar to Shecan)"
echo "--*-* DoH DNS Server Installer *-*--"
echo ""
echo "Select an option:"
echo "1) Install dnsproxy (DoH Server)"
echo "2) Uninstall dnsproxy"
echo "0) Exit"
echo "----$(check_status)----"
read -p "Enter your choice: " choice

case "$choice" in
    1)
        install_dnsproxy
        ;;
    2)
        uninstall_dnsproxy
        ;;
    0)
        exit
        ;;
    *)
        echo "Invalid choice. Please select a valid option."
        ;;
esac
