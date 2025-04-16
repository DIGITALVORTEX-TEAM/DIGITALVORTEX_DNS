# DIGITALVORTEX DNS Bypass Setup Script

This script will easily set up DIGITALVORTEX DNS Bypass on your server, helping you bypass restrictions and censorship with ease.

## What it does:

- **Server Mode (Foreign)**: Installs the Sanaei Panel on a remote server, allowing you to generate the WireGuard configuration for Iranian clients.
- **Client Mode (Iranian)**: Sets up WireGuard, dnsmasq, and iptables on your local server to connect to the external server (Sanaei Panel server).
- **Test Connection**: After setup, you can test the connection to make sure everything is working properly.

---

## How to use:

1. **Server Mode (Foreign)**:  
If you're setting up a remote server, this will install the Sanaei Panel for you. Once installed, you can generate the WireGuard configuration for Iranian clients and use that on your Iranian server.

2. **Client Mode (Iranian)**:  
Use this mode to configure your local server as a client, connecting it to the remote Sanaei Panel server via WireGuard.

3. **Test Connection**:  
After installation, test the connection to ensure that everything is working properly and DNS bypass is enabled.

---

## Installation:

1. Clone the repository or download the script.

2. Run the following command to install the script directly:

    ```bash
    bash <(curl -s https://raw.githubusercontent.com/DIGITALVORTEX-TEAM/digitalvortex-dns-bypass/main/setup.sh)
    ```

3. Follow the on-screen instructions to set up the desired mode.

---

## Testing:

Once the setup is complete, use the "Test Connection" option in the script to verify the connection is working and DNS bypass is functional.

---

# اسکریپت راه‌اندازی DIGITALVORTEX DNS Bypass

این اسکریپت به راحتی DIGITALVORTEX DNS Bypass رو روی سرور شما نصب می‌کنه و به شما کمک می‌کنه که محدودیت‌ها و سانسور رو راحت دور بزنید.

## چی کار می‌کنه:

- **حالت سرور (خارجی)**: نصب پنل سنایی روی سرور خارجی، تا بتونید کانفیگ WireGuard برای مشتری‌های ایرانی رو از پنل سنایی بگیرید.
- **حالت مشتری (ایرانی)**: نصب WireGuard، dnsmasq و iptables روی سرور محلی برای اتصال به سرور خارجی (سرور پنل سنایی).
- **تست اتصال**: بعد از نصب، می‌تونید اتصال رو تست کنید تا مطمئن بشید همه چیز به درستی کار می‌کنه.

---

## چطور استفاده کنید:

1. **حالت سرور (خارجی)**:  
اگر دارید سرور خارجی رو راه‌اندازی می‌کنید، این گزینه پنل سنایی رو نصب می‌کنه. بعد از نصب، شما می‌تونید از پنل سنایی کانفیگ WireGuard برای مشتری‌های ایرانی بسازید و این کانفیگ رو روی سرور ایران وارد کنید.

2. **حالت مشتری (ایرانی)**:  
این گزینه رو انتخاب کنید تا سرور محلی خودتون رو به عنوان مشتری پیکربندی کنید و از طریق WireGuard به سرور خارجی (سرور پنل سنایی) وصل بشید.

3. **تست اتصال**:  
بعد از نصب، می‌تونید اتصال رو تست کنید تا مطمئن بشید که همه چیز درست کار می‌کنه و DNS Bypass فعال شده.

---

## نصب:

1. این ریپازیتوری رو کلون کنید یا اسکریپت رو دانلود کنید.

2. اسکریپت رو از طریق دستور زیر به طور مستقیم نصب کنید:

    ```bash
    bash <(curl -s https://raw.githubusercontent.com/DIGITALVORTEX-TEAM/digitalvortex-dns-bypass/main/setup.sh)
    ```

3. طبق دستورالعمل‌های نمایش داده‌شده روی صفحه، حالت مورد نظر رو انتخاب کنید.

---

## تست:

بعد از نصب، از گزینه "تست اتصال" در اسکریپت استفاده کنید تا مطمئن بشید که اتصال به درستی کار می‌کنه و DNS Bypass فعال شده.

---

### ساخته شده با عشق توسط **DIGITALVORTEX**  
**Simple | Secure | Smart**
