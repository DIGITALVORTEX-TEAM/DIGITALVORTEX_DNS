#!/bin/bash

# Clear terminal screen
clear

# Display a colorful header
echo -e "\033[1;34m==========================================="
echo -e "\033[1;32m         DIGITALVORTEX DNS Bypass          "
echo -e "\033[1;34m===========================================\033[0m"

# Ask for server mode or remove option
echo -e "\033[1;36mLotfan yeki az gozineh ha ro entekhab konid\033[0m"
echo -e "\033[1;33m1) IRAN (Client)"
echo -e "2) KHAREJ (Server - Sanaei Panel)"
echo -e "3) Hazf (Remove Configuration)"
echo -e "4) Test Connection\033[0m"
read -p "Adad ra vared kon [1-4]: " MODE

# Server mode for KHAREJ (Server)
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

# Client mode for IRAN (Client)
if [ "$MODE" == "1" ]; then
    echo -e "\033[1;31m== Mode IRAN (Client) ==\033[0m"
    apt update && apt install -y wireguard iptables-persistent dnsmasq

    # Generate WireGuard keys
    wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey
    PRIVATE_KEY=$(cat /etc/wireguard/privatekey)
    PUBLIC_KEY=$(cat /etc/wireguard/publickey)

    # Clear screen and ask for server config
    clear
    echo -e "\033[1;33m===========================================\033[0m"
    echo -e "\033[1;36mLotfan config WireGuard server KHAREJ ra vared konid va ENTER bezanid.\033[0m"
    echo -e "\033[1;33m===========================================\033[0m"
    read SERVER_CONFIG

    if [[ -z "$SERVER_CONFIG" ]] || [[ "$SERVER_CONFIG" != *"[Interface]"* ]] || [[ "$SERVER_CONFIG" != *"[Peer]"* ]]; then
        echo -e "\033[1;31mError: Config gheyre sahih ast! Lotfan config sahih WireGuard ra vared konid.\033[0m"
        exit 1
    fi

    echo "$SERVER_CONFIG" > /etc/wireguard/wg0.conf

    # Enable IP forwarding
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    sysctl -p

    # Configure NAT and persistent iptables
    iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
    netfilter-persistent save

    # Enable and start WireGuard
    systemctl enable wg-quick@wg0
    systemctl start wg-quick@wg0

    # Configure dnsmasq
    echo "interface=wg0" > /etc/dnsmasq.conf
    echo "bind-interfaces" >> /etc/dnsmasq.conf
    echo "server=127.0.0.1" >> /etc/dnsmasq.conf
    systemctl enable dnsmasq
    systemctl start dnsmasq

    echo -e "\033[1;32m****************************************\033[0m"
    echo -e "\033[1;32m*    DIGITALVORTEX DNS Bypass Ready    *\033[0m"
    echo -e "\033[1;32m****************************************\033[0m"
    echo -e "\033[1;33mPublic Key Client (IRAN):\033[0m"
    echo "${PUBLIC_KEY}"
    exit 0
fi

# Remove configuration option
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

# Test Connection Option
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
