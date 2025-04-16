```markdown
# DIGITALVORTEX DNS Bypass System
![DIGITALVORTEX Logo](https://raw.githubusercontent.com/DIGITALVORTEX-TEAM/DIGITALVORTEX_DNS/main/assets/logo.png)

**Enterprise-Grade Censorship Circumvention Solution**  
**راه‌حل سازمانی برای عبور از محدودیت‌های اینترنتی**

---

## 🌐 Table of Contents
- [Features](#-features)
- [Installation](#-installation)
- [Server Modes](#-server-modes)
- [Usage](#-usage)
- [Security](#-security)
- [Support](#-support)

---

## ✨ Features

### Dual-Server Architecture
- 🇮🇷 **Iran Server**: Frontend with traffic filtering
- 🌍 **Foreign Server**: Backend with unrestricted access

### Advanced Technologies
- WireGuard VPN with obfuscation
- DNS-over-TLS/HTTPS
- Intelligent traffic routing
- Automatic failover

### Management
- Web-based control panel
- CLI management tool
- Real-time monitoring

---

## 📥 Installation

### Quick Install (Auto-Detect)
```bash
bash <(curl -s https://raw.githubusercontent.com/DIGITALVORTEX-TEAM/DIGITALVORTEX_DNS/main/install.sh)
```

### Manual Installation
1. Clone repository:
   ```bash
   git clone https://github.com/DIGITALVORTEX-TEAM/DIGITALVORTEX_DNS.git
   cd DIGITALVORTEX_DNS
   ```
2. Run installer:
   ```bash
   sudo ./install.sh
   ```

---

## ⚙️ Server Modes

### 🌍 Foreign Server Mode
```bash
curl -s https://raw.githubusercontent.com/DIGITALVORTEX-TEAM/DIGITALVORTEX_DNS/main/scripts/foreign.sh | sudo bash
```

### 🇮🇷 Iran Server Mode
```bash
curl -s https://raw.githubusercontent.com/DIGITALVORTEX-TEAM/DIGITALVORTEX_DNS/main/scripts/iran.sh | sudo bash
```

---

## 📡 Usage

### Start Service
```bash
sudo digitalvortex start
```

### Check Status
```bash
sudo digitalvortex status
```

### Test Connection
```bash
sudo digitalvortex test
```

### Update Configurations
```bash
sudo digitalvortex reconfigure
```

---

## 🔒 Security Features

| Feature               | Implementation          |
|-----------------------|-------------------------|
| Encryption            | AES-256 + ChaCha20      |
| DNS Security          | DNSSEC + DoT/DoH        |
| Authentication        | WireGuard PSK           |
| Obfuscation          | Traffic Masking         |
| Firewall             | Automated iptables Rules |

---

## 📚 Documentation

- [Full Technical Documentation](docs/TECH.md)
- [F
