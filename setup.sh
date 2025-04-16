#!/bin/bash

# Clear terminal screen
clear

# Display a colorful header
echo -e "\033[1;34m==========================================="
echo -e "\033[1;32m         DIGITALVORTEX DNS Bypass          "
echo -e "\033[1;34m===========================================\033[0m"

# Display menu
echo -e "\033[1;36mServer shoma Iranian ast, Khareji ya mikhahid hazf konid?\033[0m"
echo -e "\033[1;33m1) IRAN (Client)"
echo -e "2) KHAREJ (Server - Sanaei Panel)"
echo -e "3) Test Etessal"
echo -e "4) Hazf (Remove Configuration)\033[0m"
read -p "Adad ra vared kon [1-4]: " MODE

# Server Mode
if [ "$MODE" == "2" ]; then
    echo -e "\033[1;31m== Mode Server KHAREJ (Server) ==\033[0m"
    echo -e "\033[1;36mNasb Sanaei Panel dar hale anjam ast...\033[0m"
    bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
    echo -e "\033[1;32m*****************************************\033[0m"
    echo -e "\033[1;32m*  Server KHAREJ ba DIGITALVORTEX Ready  *\033[0m"
    echo -e "\033[1;32m****************************************\033[0m"
    echo -e "\033[1;33mBe Panel Sanaei vared shavid va config WireGuard baraye Iran Client besazid.\033[0m"
    exit 0
fi

# Client Mode
if [ "$MODE" == "1" ]; then
    echo -e "\033[1;31m== Mode IRAN (Client) ==\033[0m"
    apt update && apt install -y wireguard iptables-persistent dnsmasq

    # Prompt for WireGuard data
    read -p "Public Key Server ra vared konid: " SERVER_PUBLIC_KEY
    read -p "Private Key Client ra vared konid: " CLIENT_PRIVATE_KEY
    read -p "Endpoint Server ra vared konid (masalan IP:PORT): " SERVER_ENDPOINT

    # Validate inputs
    if [[ -z "$SERVER_PUBLIC_KEY" || -z "$CLIENT_PRIVATE_KEY" || -z "$SERVER_ENDPOINT" ]]; then
        echo -e "\033[1;31mError: Hame maghadir bayad vared shavad.\033[0m"
        exit 1
    fi

    # Generate config file
    cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = 10.0.0.2/32
DNS = 1.1.1.1, 1.0.0.1
MTU = 1420

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = $SERVER_ENDPOINT
EOF

    # Enable IP forwarding
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    sysctl -p

    # Configure iptables
    iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
    netfilter-persistent save

    # Start WireGuard
    systemctl enable wg-quick@wg0
    systemctl start wg-quick@wg0

    # Setup dnsmasq
    echo "interface=wg0" > /etc/dnsmasq.conf
    echo "bind-interfaces" >> /etc/dnsmasq.conf
    echo "server=127.0.0.1" >> /etc/dnsmasq.conf
    systemctl enable dnsmasq
    systemctl start dnsmasq

    echo -e "\033[1;32m****************************************\033[0m"
    echo -e "\033[1;32m*    DIGITALVORTEX DNS Bypass Ready    *\033[0m"
    echo -e "\033[1;32m****************************************\033[0m"
    exit 0
fi

# Test Connection
if [ "$MODE" == "3" ]; then
    echo -e "\033[1;36mChecking WireGuard Connection Status...\033[0m"
    wg show wg0 || echo -e "\033[1;31mWireGuard run nashode ya config eshtebah ast!\033[0m"
    exit 0
fi

# Remove Configuration
if [ "$MODE" == "4" ]; then
    echo -e "\033[1;31m== Hazf (Remove Configuration) ==\033[0m"
    rm -f /etc/wireguard/wg0.conf
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

# Invalid input
echo -e "\033[1;31mAdad eshtebah vared shod! Lotfan dobare sa'y konid.\033[0m"
