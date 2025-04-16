#!/bin/bash

# Clear terminal screen
clear

# Display a colorful header
echo -e "\033[1;34m===========================================\033[0m"
echo -e "\033[1;32m         DIGITALVORTEX DNS Bypass          \033[0m"
echo -e "\033[1;34m===========================================\033[0m"

# Ask for server mode or remove option
echo -e "\033[1;36mLotfan yek gozine ra entekhab konid:\033[0m"
echo -e "\033[1;33m1) Tanzim DNS roye Server Iran\033[0m"
echo -e "\033[1;33m2) Nasb Panel roye Server Kharej\033[0m"
echo -e "\033[1;33m3) Hazf (Remove Configuration)\033[0m"
echo -e "\033[1;33m4) Test Connection\033[0m"
read -p "Adad ra vared kon [1-4]: " MODE

# Server mode for KHAREJ (Hysteria)
if [ "$MODE" == "2" ]; then
    echo -e "\033[1;31m== Mode Server KHAREJ (Server) ==\033[0m"
    echo -e "\033[1;36mNasb Panel Hysteria dar hale anjam ast...\033[0m"
    bash <(curl -Ls https://raw.githubusercontent.com/ReturnFI/Hysteria2/main/install.sh)
    echo -e "\033[1;32m*****************************************\033[0m"
    echo -e "\033[1;32m*  Server KHAREJ ba DIGITALVORTEX Ready  *\033[0m"
    echo -e "\033[1;32m****************************************\033[0m"
    exit 0
fi

# Client mode for IRAN (DNS Configuration)
if [ "$MODE" == "1" ]; then
    echo -e "\033[1;31m== Mode IRAN (Client) ==\033[0m"
    apt update && apt install -y dnsmasq

    clear

    echo -e "\033[1;33m===========================================\033[0m"
    echo -e "\033[1;36mLotfan moshakhasat Hysteria server KHAREJ ra vared konid:\033[0m"

    # Request user input for Hysteria configuration
    read -p "Enter Hysteria Config (JSON): " HYSTERIA_CONFIG

    # Write the configuration to the Hysteria config file
    echo "$HYSTERIA_CONFIG" > /etc/hysteria/config.json

    # Enable Hysteria and start the service
    systemctl enable hysteria
    systemctl restart hysteria

    # Configure dnsmasq
    echo "interface=hysteria" > /etc/dnsmasq.conf
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
    rm -f /etc/hysteria/config.json
    systemctl stop hysteria
    systemctl disable hysteria
    iptables -t nat -D POSTROUTING -o hysteria -j MASQUERADE
    netfilter-persistent save
    apt-get remove --purge -y dnsmasq
    echo -e "\033[1;32m****************************************\033[0m"
    echo -e "\033[1;32m*     DIGITALVORTEX DNS Bypass Removed  *\033[0m"
    echo -e "\033[1;32m****************************************\033[0m"
    exit 0
fi

# Test connection
if [ "$MODE" == "4" ]; then
    echo -e "\033[1;34m== DIGITALVORTEX Test Connection ==\033[0m"
    if systemctl is-active --quiet hysteria; then
        echo -e "\033[1;32m[+] Hysteria: Active\033[0m"
    else
        echo -e "\033[1;31m[-] Hysteria: Inactive! Check config or start service.\033[0m"
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
    echo -e "\033[1;34mChecking internet connection via Hysteria...\033[0m"
    ping -c 3 8.8.8.8 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "\033[1;32m[+] Internet Test: Success\033[0m"
    else
        echo -e "\033[1;31m[-] Internet Test: Failed! Hysteria may not be connected.\033[0m"
    fi
    echo -e "\033[1;32mTest Completed.\033[0m"
    exit 0
fi

# Invalid input
echo -e "\033[1;31mAdad eshtebah vared shod! Lotfan dobare sa'y konid.\033[0m"
