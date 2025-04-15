#!/bin/bash

clear
echo "==========================================="
echo "         DIGITALVORTEX DNS Bypass          "
echo "==========================================="

echo "In server Iranian ast ya Khareji?"
echo "1) IRAN (Client)"
echo "2) KHAREJ (Server - Sanaei Panel)"
read -p "Adad ra vared kon [1-2]: " MODE

if [ "$MODE" == "2" ]; then
    echo "== Mode Server KHAREJ (Server) =="
    echo "Nasb Sanaei Panel dar hale anjam ast..."
    bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

    echo "*****************************************"
    echo "*  Server KHAREJ ba DIGITALVORTEX Ready  *"
    echo "*****************************************"
    echo "Be Panel Sanaei vared shavid va config ra baraye IRAN Client sakht konid."
    exit 0
fi

if [ "$MODE" == "1" ]; then
    echo "== Mode IRAN (Client) =="
    apt update && apt install -y wireguard iptables-persistent

    wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey
    PRIVATE_KEY=$(cat /etc/wireguard/privatekey)
    PUBLIC_KEY=$(cat /etc/wireguard/publickey)

    echo "Lotfan file config server KHAREJ ra paste konid:"
    read -p "Paste config in yeki line va ENTER bezanid: " SERVER_CONFIG

    echo "$SERVER_CONFIG" > /etc/wireguard/wg0.conf

    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    sysctl -p

    iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
    netfilter-persistent save

    systemctl enable wg-quick@wg0
    systemctl start wg-quick@wg0

    echo "****************************************"
    echo "*    DIGITALVORTEX DNS Bypass Ready    *"
    echo "****************************************"
    echo "Public Key Client (IRAN):"
    echo "${PUBLIC_KEY}"
else
    echo "Adad eshtebah vared shod! Do bare sa'y konid."
fi
