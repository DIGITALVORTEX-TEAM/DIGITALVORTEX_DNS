#!/bin/bash

# Clear terminal screen
clear

# Display a colorful header
echo -e "\033[1;34m===========================================\033[0m"
echo -e "\033[1;32m         DIGITALVORTEX DNS Bypass          \033[0m"
echo -e "\033[1;34m===========================================\033[0m"

# Ask for server mode or remove option
echo -e "\033[1;36mLotfan yek gozine ra entekhab konid:\033[0m"
echo -e "\033[1;33m1) IRAN (Client)\033[0m"
echo -e "\033[1;33m2) KHAREJ (Server - Sanaei Panel)\033[0m"
echo -e "\033[1;33m3) Hazf (Remove Configuration)\033[0m"
echo -e "\033[1;33m4) Test Connection\033[0m"
read -p "Adad ra vared kon [1-4]: " MODE

# Server mode for KHAREJ
if [ "$MODE" == "2" ]; then
    echo -e "\033[1;31m== Mode Server KHAREJ (Server) ==\033[0m"
    echo -e "\033[1;36mNasb Sanaei Panel dar hale anjam ast...\033[0m"
    bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
    echo -e "\033[1;32m*****************************************\033[0m"
    echo -e "\033[1;32m*  Server KHAREJ ba DIGITALVORTEX Ready  *\033[0m"
    echo -e "\033[1;32m****************************************\033[0m"
    echo -e "\033[1;33mBe Panel Sanaei vared shavid va config ra baraye IRAN Client sakht konid.\033[0m"
    exit 0
fi

# Client mode for IRAN
if [ "$MODE" == "1" ]; then
    echo -e "\033[1;31m== Mode IRAN (Client) ==\033[0m"
    apt update && apt install -y wireguard iptables-persistent dnsmasq

    clear

    echo -e "\033[1;33m===========================================\033[0m"
    echo -e "\033[1;36mLotfan moshakhasat WireGuard server KHAREJ ra vared konid:\033[0m"

    # Request user input for PrivateKey, PublicKey, and Endpoint
    read -p "PrivateKey: " PRIVATE_KEY
    read -p "PublicKey: " PUBLIC_KEY
    read -p "Endpoint (e.g., 127.0.0.1:12345): " ENDPOINT

    # Write the configuration to the WireGuard config file
    cat > /etc/wireguard/wg0.conf <<EOL
[Interface]
PrivateKey = $PRIVATE_KEY
Address = 10.0.0.2/32
DNS = 1.1.1.1, 1.0.0.1
MTU = 1420

[Peer]
PublicKey = $PUBLIC_KEY
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = $ENDPOINT
EOL

    # Enable IP forwarding
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    sysctl -p

    # Configure NAT and persistent iptables
    iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
    netfilter-persistent save

    # Enable and start WireGuard
    systemctl enable wg-quick@wg0
    systemctl restart wg-quick@wg0

    # Check if WireGuard is active
    if ! systemctl is-active --quiet wg-quick@wg0; then
        echo -e "\033[1;31m[-] Error: WireGuard could not be restarted.\033[0m"
        journalctl -u wg-quick@wg0 --since "1 minute ago" | tail -n 10
        exit 1
    fi

    # Configure dnsmasq
    echo "interface=wg0" > /etc/dnsmasq.conf
    echo "bind-interfaces" >> /etc/dnsmasq.conf
    echo "server=127.0.0.1" >> /etc/dnsmasq.conf
    systemctl enable dnsmasq
    systemctl restart dnsmasq

    echo -e "\033[1;32m****************************************\033[0m"
    echo -e "\033[1;32m*    DIGITALVORTEX DNS Bypass Ready    *\033[0m"
    echo -e "\033[1;32m****************************************\033[0m"
    exit 0
fi

# Remove configuration
if [ "$MODE" == "3" ]; then
    echo -e "\033[1;31m== Hazf (Remove Configuration) ==\033[0m"
    echo -e "\033[1;36mDar hale hazf tamam nasb ha va file ha...\033[0m"
    rm -f /etc/wireguard/wg0.conf
    rm -f /etc/wireguard/privatekey
    rm -f /etc/wireguard/publickey
    systemctl stop wg-quick@wg0
    systemctl disable wg-quick@wg0
    iptables -t nat -D POSTROUTING -o wg0 -j MASQUERADE
    netfilter-persistent save
    apt-get remove --purge -y wireguard iptables-persistent dnsmasq
    echo -e "\033[1;32m****************************************\033[0m"
    echo -e "\033[1;32m*     DIGITALVORTEX DNS Bypass Removed  *\033[0m"
    echo -e "\033[1;32m****************************************\033[0m"
    exit 0
fi

# Test connection
if [ "$MODE" == "4" ]; then
    echo -e "\033[1;34m== DIGITALVORTEX Test Connection ==\033[0m"
    if systemctl is-active --quiet wg-quick@wg0; then
        echo -e "\033[1;32m[+] WireGuard: Active\033[0m"
    else
        echo -e "\033[1;31m[-] WireGuard: Inactive! Check config or start service.\033[0m"
    fi
    if systemctl is-active --quiet dnsmasq; then
        echo -e "\033[1;32m[+] dnsmasq: Active\033[0m"
    else
        echo -e "\033[1;31m[-] dnsmasq: Inactive! Check service status.\033[0m"
    fi
    if iptables -t nat -S | grep -q "MASQUERADE"; then
        echo -e "\033[1;32m[+] iptables NAT: OK\033[0m"
    else
        echo -e "\033[1;31m[-] iptables NAT: Not Set! Check iptables rules.\033[0m"
    fi
    echo -e "\033[1;34mChecking internet connection via WireGuard...\033[0m"
    ping -c 3 8.8.8.8 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "\033[1;32m[+] Internet Test: Success\033[0m"
    else
        echo -e "\033[1;31m[-] Internet Test: Failed! WireGuard may not be connected.\033[0m"
    fi
    echo -e "\033[1;32mTest Completed.\033[0m"
    exit 0
fi

# Invalid input
echo -e "\033[1;31mAdad eshtebah vared shod! Lotfan dobare sa'y konid.\033[0m"
