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
    apt update && apt install -y shadowsocks-libev iptables-persistent dnsmasq

    clear

    echo -e "\033[1;33m===========================================\033[0m"
    echo -e "\033[1;36mLotfan moshakhasat Shadowsocks server KHAREJ ra vared konid:\033[0m"

    # Request user input for server address, password, and method
    read -p "Server Address (e.g., 5.75.205.201): " SERVER_ADDR
    read -p "Port (e.g., 8388): " PORT
    read -p "Password: " PASSWORD
    read -p "Encryption Method (e.g., aes-256-gcm): " METHOD

    # Write the configuration to the Shadowsocks config file
    cat > /etc/shadowsocks-libev/config.json <<EOL
{
    "server": "$SERVER_ADDR",
    "server_port": $PORT,
    "password": "$PASSWORD",
    "method": "$METHOD",
    "timeout": 300
}
EOL

    # Start Shadowsocks
    systemctl enable shadowsocks-libev
    systemctl start shadowsocks-libev

    # Configure dnsmasq
    echo "interface=lo" > /etc/dnsmasq.conf
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
    rm -f /etc/shadowsocks-libev/config.json
    systemctl stop shadowsocks-libev
    systemctl disable shadowsocks-libev
    apt-get remove --purge -y shadowsocks-libev iptables-persistent dnsmasq
    echo -e "\033[1;32m****************************************\033[0m"
    echo -e "\033[1;32m*     DIGITALVORTEX DNS Bypass Removed  *\033[0m"
    echo -e "\033[1;32m****************************************\033[0m"
    exit 0
fi

# Test connection
if [ "$MODE" == "4" ]; then
    echo -e "\033[1;34m== DIGITALVORTEX Test Connection ==\033[0m"
    if systemctl is-active --quiet shadowsocks-libev; then
        echo -e "\033[1;32m[+] Shadowsocks: Active\033[0m"
    else
        echo -e "\033[1;31m[-] Shadowsocks: Inactive! Check config or start service.\033[0m"
    fi
    if systemctl is-active --quiet dnsmasq; then
        echo -e "\033[1;32m[+] dnsmasq: Active\033[0m"
    else
        echo -e "\033[1;31m[-] dnsmasq: Inactive! Check service status.\033[0m"
    fi
    echo -e "\033[1;32mTest Completed.\033[0m"
    exit 0
fi

# Invalid input
echo -e "\033[1;31mAdad eshtebah vared shod! Lotfan dobare sa'y konid.\033[0m"
