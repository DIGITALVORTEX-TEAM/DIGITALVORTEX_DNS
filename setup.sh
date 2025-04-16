#!/bin/bash

# Clear terminal screen
clear

# Display a colorful header
echo -e "\033[1;34m==========================================="
echo -e "\033[1;32m         DIGITALVORTEX DNS Bypass          "
echo -e "\033[1;34m===========================================\033[0m"

# Ask for server mode or remove option
echo -e "\033[1;36mLotfan yek gozine ra entekhab konid:\033[0m"
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
    echo -e "\033[1;32m*****************************************\033[0m"
    echo -e "\033[1;33mBe Panel Sanaei vared shavid va config ra baraye IRAN Client sakht konid.\033[0m"
    exit 0
fi

# Client mode for IRAN (Client)
if [ "$MODE" == "1" ]; then
    echo -e "\033[1;31m== Mode IRAN (Client) ==\033[0m"
    apt update && apt install -y wireguard iptables-persistent dnsmasq

    clear
    echo -e "\033[1;33m===========================================\033[0m"
    echo -e "\033[1;36mLotfan config WireGuard server KHAREJ ra kamelan copy-paste konid.\033[0m"
    echo -e "\033[1;36mPas az vared kardan, CTRL+D bezanid ta sabt shavad.\033[0m"
    echo -e "\033[1;33m===========================================\033[0m"

    cat > /etc/wireguard/wg0.conf

    # Check config content
    if ! grep -q "Interface" /etc/wireguard/wg0.conf || ! grep -q "Peer" /etc/wireguard/wg0.conf; then
        echo -e "\033[1;31mError: Config gheyre sahih ast! Ebarat [Interface] ya [Peer] yaft nashod.\033[0m"
        rm -f /etc/wireguard/wg0.conf
        exit 1
    fi

    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    sysctl -p

    iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
    netfilter-persistent save

    systemctl enable wg-quick@wg0
    systemctl start wg-quick@wg0

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

# Remove configuration option
if [ "$MODE" == "3" ]; then
    echo -e "\033[1;31m== Hazf (Remove Configuration) ==\033[0m"
    echo -e "\033[1;36mDar hale hazf tamam nasb ha va file ha...\033[0m"

    rm -f /etc/wireguard/wg0.conf /etc/wireguard/privatekey /etc/wireguard/publickey
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

    systemctl is-active --quiet wg-quick@wg0 && echo -e "\033[1;32m[+] WireGuard: Active\033[0m" || echo -e "\033[1;31m[-] WireGuard: Inactive!\033[0m"
    systemctl is-active --quiet dnsmasq && echo -e "\033[1;32m[+] dnsmasq: Active\033[0m" || echo -e "\033[1;31m[-] dnsmasq: Inactive!\033[0m"

    if iptables -t nat -S | grep -q "MASQUERADE"; then
        echo -e "\033[1;32m[+] iptables NAT: OK\033[0m"
    else
        echo -e "\033[1;31m[-] iptables NAT: Not Set!\033[0m"
    fi

    echo -e "\033[1;34mChecking internet connection via WireGuard...\033[0m"
    ping -c 3 8.8.8.8 > /dev/null 2>&1 && echo -e "\033[1;32m[+] Internet Test: Success\033[0m" || echo -e "\033[1;31m[-] Internet Test: Failed!\033[0m"

    echo -e "\033[1;32mTest Completed.\033[0m"
    exit 0
fi

# Invalid input
echo -e "\033[1;31mAdad eshtebah vared shod! Lotfan dobare sa'y konid.\033[0m"
