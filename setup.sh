#!/bin/bash

clear
echo -e "\033[1;34m==========================================="
echo -e "\033[1;32m         DIGITALVORTEX DNS Bypass          "
echo -e "\033[1;34m===========================================\033[0m"

echo -e "\033[1;36mServer shoma Iranian ast, Khareji ya mikhahid hazf konid?\033[0m"
echo -e "\033[1;33m1) IRAN (Client)"
echo -e "2) KHAREJ (Server - Sanaei Panel)"
echo -e "3) Hazf (Remove Configuration)\033[0m"
read -p "Adad ra vared kon [1-3]: " MODE

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

if [ "$MODE" == "1" ]; then
    echo -e "\033[1;31m== Mode IRAN (Client) ==\033[0m"
    apt update && apt install -y wireguard iptables-persistent dnsmasq

    wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey
    PRIVATE_KEY=$(cat /etc/wireguard/privatekey)
    PUBLIC_KEY=$(cat /etc/wireguard/publickey)

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

    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    sysctl -p

    systemctl enable wg-quick@wg0
    systemctl start wg-quick@wg0

    # Configure dnsmasq
    echo "interface=wg0" > /etc/dnsmasq.conf
    echo "bind-interfaces" >> /etc/dnsmasq.conf
    echo "server=8.8.8.8" >> /etc/dnsmasq.conf  # Google DNS
    systemctl enable dnsmasq
    systemctl restart dnsmasq

    # Transparent Routing (Like RadarGame)
    WG_TUNNEL_IP="10.0.0.1"   # IP side server KHAREJ dar config WireGuard
    EXT_IFACE=$(ip route get 1 | awk '{print $5; exit}')
    
    iptables -t nat -A PREROUTING -i $EXT_IFACE ! -d $(hostname -I | awk '{print $1}') -j DNAT --to-destination $WG_TUNNEL_IP
    iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
    netfilter-persistent save

    echo -e "\033[1;32m****************************************\033[0m"
    echo -e "\033[1;32m*    DIGITALVORTEX DNS Bypass Ready    *\033[0m"
    echo -e "\033[1;32m****************************************\033[0m"
    echo -e "\033[1;33mPublic Key Client (IRAN):\033[0m"
    echo "${PUBLIC_KEY}"
    exit 0
fi

if [ "$MODE" == "3" ]; then
    echo -e "\033[1;31m== Hazf (Remove Configuration) ==\033[0m"
    echo -e "\033[1;36mDar hale hazf tamam nasb ha va file ha...\033[0m"

    rm -f /etc/wireguard/wg0.conf
    rm -f /etc/wireguard/privatekey
    rm -f /etc/wireguard/publickey

    systemctl stop wg-quick@wg0
    systemctl disable wg-quick@wg0

    iptables -t nat -F
    netfilter-persistent save

    apt-get remove --purge -y wireguard iptables-persistent dnsmasq

    echo -e "\033[1;32m****************************************\033[0m"
    echo -e "\033[1;32m*     DIGITALVORTEX DNS Bypass Removed  *\033[0m"
    echo -e "\033[1;32m****************************************\033[0m"
    exit 0
fi

echo -e "\033[1;31mAdad eshtebah vared shod! Lotfan dobare sa'y konid.\033[0m"
