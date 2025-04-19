#!/bin/bash

# Clear Terminal
clear

# DIGITALVORTEX Stylish Banner
echo -e "\033[1;35m===============================================\033[0m"
echo -e "\033[1;36m          DIGITALVORTEX DNS BYPASS            \033[0m"
echo -e "\033[1;35m===============================================\033[0m"

# Menu
echo -e "\033[1;33mLotfan Role mored nazar ro entekhab kon:\033[0m"
echo -e "\033[1;32m1) Server IRAN (DNS Forwarder)\033[0m"
echo -e "\033[1;34m2) Server KHAREJ (DoH Server with CoreDNS)\033[0m"
echo -e "\033[1;31m3) Remove DIGITALVORTEX Setup\033[0m"
echo -e "\033[1;36m4) Test DIGITALVORTEX Connection\033[0m"
read -p "Adad mored nazar ro vared kon (1-4): " MODE

if [ "$MODE" == "2" ]; then
    echo -e "\033[1;34m== Mode Server KHAREJ (DoH Server) ==\033[0m"
    apt update && apt install -y curl wget unzip systemd
    wget https://github.com/coredns/coredns/releases/download/v1.11.1/coredns_1.11.1_linux_amd64.tgz
    tar -xvzf coredns_1.11.1_linux_amd64.tgz
    mv coredns /usr/local/bin/

    cat > /etc/coredns/Corefile <<EOF
.:443 {
    tls your-cert.pem your-key.pem
    forward . 8.8.8.8 1.1.1.1
    log
    errors
}
EOF

    cat > /etc/systemd/system/coredns.service <<EOF
[Unit]
Description=CoreDNS
After=network.target

[Service]
ExecStart=/usr/local/bin/coredns -conf /etc/coredns/Corefile
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable coredns
    systemctl start coredns

    echo -e "\033[1;32mDIGITALVORTEX KHAREJ DoH Server Ready!\033[0m"
    exit 0
fi

if [ "$MODE" == "1" ]; then
    echo -e "\033[1;32m== Mode Server IRAN (DNS Forwarder) ==\033[0m"
    apt update && apt install -y dnsmasq

    read -p "DoH Server KHAREJ IP ro vared kon: " DOH_IP

    cat > /etc/dnsmasq.conf <<EOF
server=$DOH_IP#443
listen-address=127.0.0.1
no-resolv
EOF

    systemctl enable dnsmasq
    systemctl restart dnsmasq

    echo -e "\033[1;32mDIGITALVORTEX IRAN Server DNS Forwarder Ready!\033[0m"
    exit 0
fi

if [ "$MODE" == "3" ]; then
    echo -e "\033[1;31m== DIGITALVORTEX Removing Setup ==\033[0m"
    systemctl stop coredns dnsmasq
    systemctl disable coredns dnsmasq
    rm -f /usr/local/bin/coredns /etc/coredns/Corefile /etc/systemd/system/coredns.service
    apt-get remove --purge -y dnsmasq
    systemctl daemon-reload
    echo -e "\033[1;32mDIGITALVORTEX Successfully Removed!\033[0m"
    exit 0
fi

if [ "$MODE" == "4" ]; then
    echo -e "\033[1;36m== DIGITALVORTEX Test Connection ==\033[0m"
    if systemctl is-active --quiet coredns; then
        echo -e "\033[1;32m[+] CoreDNS: Active\033[0m"
    else
        echo -e "\033[1;31m[-] CoreDNS: Not Running\033[0m"
    fi
    if systemctl is-active --quiet dnsmasq; then
        echo -e "\033[1;32m[+] dnsmasq: Active\033[0m"
    else
        echo -e "\033[1;31m[-] dnsmasq: Not Running\033[0m"
    fi
    echo -e "\033[1;36mTest Completed!\033[0m"
    exit 0
fi

# Invalid Option
echo -e "\033[1;31mAdad eshtebah vared shod! Doobare talash kon.\033[0m"
