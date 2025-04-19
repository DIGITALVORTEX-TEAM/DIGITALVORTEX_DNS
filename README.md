# 🌐 DIGITALVORTEX DNS BYPASS

## 💡 English Description
DIGITALVORTEX is a **simple, stylish, and user-friendly DNS Bypass System** — designed to bypass **filters and sanctions** with 2 smart server roles:

- 🟢 `Server IRAN`: Acts as a DNS Forwarder using `dnsmasq`. Sends all DNS queries to your foreign server.
- 🔵 `Server KHAREJ`: Runs a `DoH Server` using `CoreDNS` + TLS. Breaks sanctions and unlocks all websites.

🎯 **Goal:**  
Your devices will only see the IRAN server IP, but in reality, DNS requests pass through your KHAREJ DoH server — bypassing sanctions and unlocking everything.

---

## ⚙️ How to Install?

1️⃣ Connect to your server via SSH.  
2️⃣ Run this simple command:
```bash
bash <(curl -s https://raw.githubusercontent.com/DIGITALVORTEX-TEAM/DIGITALVORTEX_DNS/main/setup.sh)
```

3️⃣ Select your mode:

- `1)` IRAN Server — DNS Forwarder.
- `2)` KHAREJ Server — DoH Server with CoreDNS.
- `3)` Remove Configurations.
- `4)` Test Server Connection.

---

## 💡 Requirements

### For KHAREJ Server:
- VPS with public IPv4 and port `443` open.
- Valid TLS certificate (`.pem`) and private key.

### For IRAN Server:
- VPS or Mikrotik or any Linux system supporting `dnsmasq`.

---

## 🧠 Note:

- Fully written in Fingilish — easy and fun!
- `dnsmasq` forwards traffic directly to KHAREJ IP.
- CoreDNS + TLS hides your domain, clients will always see IRAN server's IP.

---

## 🌀 DIGITALVORTEX Features:

- Unlock all websites — No more sanctions!
- DNS Bypass with IRAN server's IP.
- CoreDNS-based DoH server on KHAREJ.
- Super simple and stylish interactive installer.

---

---

## 💡 توضیحات فارسی

DIGITALVORTEX یک سیستم **DNS Bypass خیلی ساده و خوشگل و یوزرفرندلی** هست که برای دور زدن **فیلترینگ و تحریم‌ها** طراحی شده، با دو حالت:

- 🟢 `سرور ایران`: یک **DNS Forwarder** هست که با `dnsmasq` تنظیم میشه و تمام درخواست‌های DNS رو به سرور خارج میفرسته.
- 🔵 `سرور خارج`: یک **DoH Server** هست با `CoreDNS` و `TLS Certificate` که تمام تحریم‌ها رو از بین می‌بره.

🎯 **هدف:**  
کلاینت‌ها فقط IP سرور ایران رو می‌بینن، ولی ترافیک DNS از طریق سرور خارج و DoH رد میشه و همه سایت‌ها آزاد میشن.

---

## ⚙️ آموزش نصب

۱- به سرورت SSH بزن.  
۲- این دستور رو اجرا کن:
```bash
bash <(curl -s https://raw.githubusercontent.com/DIGITALVORTEX-TEAM/DIGITALVORTEX_DNS/main/setup.sh)
```

۳- یکی از گزینه‌ها رو انتخاب کن:

- `1)` سرور ایران — تنظیم DNS Forwarder.
- `2)` سرور خارج — نصب DoH Server با CoreDNS.
- `3)` حذف تمام تنظیمات.
- `4)` تست وضعیت اتصال.

---

## 💡 نیازمندی‌ها

### برای سرور خارج:
- سرور VPS با IP عمومی و پورت `443` باز.
- TLS Certificate معتبر (`.pem`) و Private Key.

### برای سرور ایران:
- هر VPS یا سیستم لینوکسی که بتونه `dnsmasq` نصب کنه.

---

## 🧠 نکته:

- همه چیز به فینگلیش نوشته شده، خیلی ساده و جذاب!
- `dnsmasq` تمام درخواست‌ها رو مستقیم به IP سرور خارج ارسال می‌کنه.
- `CoreDNS` با TLS جلوی لو رفتن دامین رو می‌گیره و فقط IP ایران برای کاربر نمایش داده میشه.

---

## 🌀 ویژگی‌های DIGITALVORTEX:

- رفع کامل تحریم برای همه سایت‌ها.
- عبور DNS از سرور خارج ولی نمایش IP سرور ایران.
- DoH Server قدرتمند با CoreDNS و TLS.
- نصب فوق‌العاده ساده، شیک و سریع.

---

🧠 اگر سوالی داشتی یا خواستی شخصی‌سازیش کنی — هر موقع بگو!  
طراحی با ❤️ توسط تیم **DIGITALVORTEX**
