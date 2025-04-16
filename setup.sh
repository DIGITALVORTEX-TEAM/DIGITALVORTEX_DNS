#!/bin/bash

clear

echo -e "\033[1;34m===========================================\033[0m"
echo -e "\033[1;32m         DIGITALVORTEX Hysteria Setup      \033[0m"
echo -e "\033[1;34m===========================================\033[0m"

echo -e "\033[1;36mلطفاً یک گزینه را انتخاب کنید:\033[0m"
echo -e "\033[1;33m1) IRAN (Client)\033[0m"
echo -e "\033[1;33m2) KHAREJ (Server - Hysteria Panel)\033[0m"
echo -e "\033[1;33m3) حذف تنظیمات\033[0m"
echo -e "\033[1;33m4) تست اتصال\033[0m"
read -p "عدد را وارد کنید [1-4]: " MODE

# حالت سرور KHAREJ
if [ "$MODE" == "2" ]; then
    echo -e "\033[1;31m== حالت سرور KHAREJ ==\033[0m"
    echo -e "\033[1;36mنصب پنل مدیریت Hysteria در حال انجام است...\033[0m"
    bash <(curl -Ls https://raw.githubusercontent.com/ReturnFI/Hysteria2/main/hysteria2.sh)
    echo -e "\033[1;32m*****************************************\033[0m"
    echo -e "\033[1;32m*  سرور KHAREJ با DIGITALVORTEX آماده است  *\033[0m"
    echo -e "\033[1;32m*****************************************\033[0m"
    echo -e "\033[1;33mبه پنل Hysteria وارد شوید و کانفیگ را برای کلاینت IRAN ایجاد کنید.\033[0m"
    exit 0
fi

# حالت کلاینت IRAN
if [ "$MODE" == "1" ]; then
    echo -e "\033[1;31m== حالت IRAN (Client) ==\033[0m"
    apt update && apt install -y curl dnsmasq

    clear

    echo -e "\033[1;33m===========================================\033[0m"
    echo -e "\033[1;36mلطفاً کانفیگ Hysteria را وارد کنید:\033[0m"

    read -p "آدرس سرور (مثال: example.com): " SERVER_ADDRESS
    read -p "پورت (مثال: 443): " SERVER_PORT
    read -p "رمز عبور: " PASSWORD

    # ایجاد فایل کانفیگ Hysteria
    cat > /etc/hysteria/config.yaml <<EOL
server: $SERVER_ADDRESS:$SERVER_PORT
auth: $PASSWORD
alpn:
  - h3
protocol: udp
obfs: ""
EOL

    # نصب Hysteria
    curl -fsSL https://github.com/apernet/hysteria/releases/latest/download/hysteria-linux-amd64 -o /usr/local/bin/hysteria
    chmod +x /usr/local/bin/hysteria

    # راه‌اندازی Hysteria
    nohup hysteria client -c /etc/hysteria/config.yaml > /var/log/hysteria.log 2>&1 &

    # تنظیم dnsmasq
    echo "interface=lo" > /etc/dnsmasq.conf
    echo "bind-interfaces" >> /etc/dnsmasq.conf
    echo "server=127.0.0.1" >> /etc/dnsmasq.conf
    systemctl enable dnsmasq
    systemctl restart dnsmasq

    echo -e "\033[1;32m****************************************\033[0m"
    echo -e "\033[1;32m*    DIGITALVORTEX Hysteria آماده است    *\033[0m"
    echo -e "\033[1;32m****************************************\033[0m"
    exit 0
fi

# حذف تنظیمات
if [ "$MODE" == "3" ]; then
    echo -e "\033[1;31m== حذف تنظیمات ==\033[0m"
    echo -e "\033[1;36mدر حال حذف تمام نصب‌ها و فایل‌ها...\033[0m"
    pkill hysteria
    rm -f /usr/local/bin/hysteria
    rm -rf /etc/hysteria
    systemctl stop dnsmasq
    systemctl disable dnsmasq
    apt-get remove --purge -y dnsmasq
    echo -e "\033[1;32m****************************************\033[0m"
    echo -e "\033[1;32m*     DIGITALVORTEX Hysteria حذف شد     *\033[0m"
    echo -e "\033[1;32m****************************************\033[0m"
    exit 0
fi

# تست اتصال
if [ "$MODE" == "4" ]; then
    echo -e "\033[1;34m== تست اتصال DIGITALVORTEX ==\033[0m"
    if pgrep -x "hysteria" > /dev/null; then
        echo -e "\033[1;32m[+] Hysteria: فعال\033[0m"
    else
        echo -e "\033[1;31m[-] Hysteria: غیرفعال! کانفیگ را بررسی کنید.\033[0m"
    fi
    if systemctl is-active --quiet dnsmasq; then
        echo -e "\033[1;32m[+] dnsmasq: فعال\033[0m"
    else
        echo -e "\033[1;31m[-] dnsmasq: غیرفعال! وضعیت سرویس را بررسی کنید.\033[0m"
    fi
    echo -e "\033[1;34mبررسی اتصال اینترنت از طریق Hysteria...\033[0m"
    ping -c 3 8.8.8.8 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "\033[1;32m[+] تست اینترنت: موفق\033[0m"
    else
        echo -e "\033[1;31m[-] تست اینترنت: ناموفق! ممکن است Hysteria متصل نباشد.\033[0m"
    fi
    echo -e "\033[1;32mتست کامل شد.\033[0m"
    exit 0
fi

# ورودی نامعتبر
echo -e "\033[1;31mعدد اشتباه وارد شده است! لطفاً دوب0
