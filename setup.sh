#!/bin/bash
# DIGITALVORTEX_DNS - Smart DNS Management System
# GitHub: https://github.com/yourusername/DIGITALVORTEX_DNS
# License: MIT

# ==================== CONFIGURATION ====================
IRAN_DNS="178.22.122.100"  # دی‌ان‌اس پیش‌فرض ایران (مثل Shecan)
FOREIGN_DNS="8.8.8.8"       # دی‌ان‌اس خارج (Google DNS)
CONFIG_DIR="/etc/digitalvortex"
LOG_FILE="/var/log/digitalvortex.log"
INSTALL_MODE=""             # Modes: iran, foreign, standalone
# ======================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ASCII Art
show_banner() {
  clear
  echo -e "${CYAN}"
  echo '  ____  ____ ___ _____ _   _ ____  ____  ____  _____ ____ ____  '
  echo ' |  _ \|  _ \_ _|_   _| | | |  _ \|  _ \|  _ \| ____/ ___/ ___| '
  echo ' | | | | | | | |  | | | |_| | | | | |_) | | | |  _| \___ \___ \ '
  echo ' | |_| | |_| | |  | | |  _  | |_| |  _ <| |_| | |___ ___) |__) |'
  echo ' |____/|____/___| |_| |_| |_|____/|_| \_\____/|_____|____/____/ '
  echo '                    DNS Management System v2.0'
  echo -e "${NC}"
}

# Main Menu
show_menu() {
  show_banner
  echo -e "${GREEN}Select an option:${NC}"
  echo -e "1) ${YELLOW}Install on Iran Server${NC}"
  echo -e "2) ${YELLOW}Install on Foreign Server${NC}"
  echo -e "3) ${YELLOW}Standalone Mode (Foreign Only)${NC}"
  echo -e "4) ${YELLOW}Test DNS Connection${NC}"
  echo -e "5) ${YELLOW}Uninstall DIGITALVORTEX_DNS${NC}"
  echo -e "6) ${RED}Exit${NC}"
  echo -n -e "${BLUE}Enter your choice [1-6]: ${NC}"
}

# ==================== CORE FUNCTIONS ====================

install_dependencies() {
  echo -e "${YELLOW}[+] Installing required packages...${NC}"
  apt-get update -qq
  apt-get install -y -qq unbound bind9 dnsutils net-tools
}

configure_iran_server() {
  echo -e "${GREEN}[+] Configuring Iran Server (Frontend)...${NC}"
  cat > /etc/unbound/unbound.conf <<EOL
server:
  interface: 0.0.0.0
  access-control: 0.0.0.0/0 allow
  do-tcp: yes
  prefetch: yes
  
forward-zone:
  name: "."
  forward-addr: $FOREIGN_DNS
EOL
  systemctl restart unbound
}

configure_foreign_server() {
  echo -e "${GREEN}[+] Configuring Foreign Server (Backend)...${NC}"
  cat > /etc/bind/named.conf.options <<EOL
options {
  directory "/var/cache/bind";
  recursion yes;
  allow-query { any; };
  forwarders { 8.8.8.8; 1.1.1.1; };
  forward only;
  dnssec-enable yes;
  querylog yes;
};
EOL
  systemctl restart bind9
}

configure_standalone() {
  configure_foreign_server
  echo -e "${YELLOW}[+] Additional standalone optimizations...${NC}"
  apt-get install -y -qq dnscrypt-proxy
}

test_connection() {
  echo -e "${CYAN}[+] Testing DNS resolution...${NC}"
  for domain in google.com youtube.com twitter.com instagram.com; do
    echo -n "Testing $domain: "
    result=$(dig +short @127.0.0.1 $domain)
    [ -z "$result" ] && echo -e "${RED}FAIL${NC}" || echo -e "${GREEN}PASS${NC}"
  done
}

uninstall() {
  echo -e "${RED}[!] Uninstalling DIGITALVORTEX_DNS...${NC}"
  systemctl stop unbound bind9
  apt-get remove -y unbound bind9 dnscrypt-proxy
  rm -rf $CONFIG_DIR
  echo -e "${GREEN}[+] Uninstallation complete!${NC}"
}

# ==================== MAIN EXECUTION ====================

while true; do
  show_menu
  read choice
  
  case $choice in
    1) install_dependencies; configure_iran_server ;;
    2) install_dependencies; configure_foreign_server ;;
    3) install_dependencies; configure_standalone ;;
    4) test_connection ;;
    5) uninstall ;;
    6) exit 0 ;;
    *) echo -e "${RED}Invalid option!${NC}" ;;
  esac
  
  read -p "Press [Enter] to continue..."
done
