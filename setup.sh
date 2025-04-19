#!/bin/bash

# --- DIGITALVORTEX DNS Bypass Setup with Hysteria ---
# Written in Fingilish, for all users!

clear

echo "🌐 Welcome to DIGITALVORTEX DNS Bypass Setup with Hysteria!"
echo "🔧 Please choose your mode:"
echo "1) Set up Iran Server - DNS Forwarder (dnsmasq)"
echo "2) Set up Kharej Server - DoH Server (CoreDNS)"
echo "3) Set up Hysteria VPN for full internet bypass"
echo "4) Remove all configurations"
echo "5) Test Server Connection"

read -p "Enter your choice: " choice

# --- Iran Server Setup ---
if [ "$choice" -eq 1 ]; then
  echo "🟢 Setting up Iran Server (DNS Forwarder with dnsmasq)..."
  
  # Install dnsmasq
  sudo apt update
  sudo apt install -y dnsmasq
  
  echo "🔧 Configuring dnsmasq..."
  # Create a basic dnsmasq configuration file
  echo "
  server=8.8.8.8
  server=8.8.4.4
  address=/example.com/37.202.222.218 # Replace with actual domain-to-IP mappings
  " | sudo tee /etc/dnsmasq.conf > /dev/null
  
  # Restart dnsmasq to apply changes
  sudo systemctl restart dnsmasq
  echo "✅ Iran Server DNS Forwarder (dnsmasq) setup completed!"
fi

# --- Kharej Server Setup ---
if [ "$choice" -eq 2 ]; then
  echo "🔵 Setting up Kharej Server (DoH Server with CoreDNS)..."
  
  # Install CoreDNS
  sudo apt update
  sudo apt install -y curl
  curl -s https://github.com/coredns/coredns/releases/download/v1.9.0/coredns_1.9.0_linux_amd64.tgz | tar -xz
  sudo mv coredns /usr/local/bin/
  
  echo "🔧 Configuring CoreDNS for DoH (DNS over HTTPS)..."
  # Create CoreDNS config file for DoH
  echo "
  . {
    forward . 8.8.8.8
    log
    tls /path/to/cert.pem /path/to/key.pem
    # Additional DoH settings
  }
  " | sudo tee /etc/coredns/Corefile > /dev/null
  
  # Start CoreDNS service
  sudo systemctl start coredns
  sudo systemctl enable coredns
  echo "✅ Kharej Server DoH setup completed!"
fi

# --- Hysteria VPN Setup ---
if [ "$choice" -eq 3 ]; then
  echo "🔒 Setting up Hysteria VPN for full internet bypass..."
  
  # Install Hysteria
  curl -fsSL https://github.com/HyNetwork/hysteria/releases/download/v1.1.0/hysteria-linux-amd64-v1.1.0.tar.gz | tar -xz
  sudo mv hysteria /usr/local/bin/
  
  # Create Hysteria configuration
  echo "
  # Hysteria server config
  listen = 0.0.0.0:443
  cert = /path/to/cert.pem
  key = /path/to/key.pem
  mtu = 1350
  " | sudo tee /etc/hysteria/hysteria_server.conf > /dev/null
  
  # Start Hysteria server
  sudo systemctl start hysteria
  sudo systemctl enable hysteria
  echo "✅ Hysteria VPN setup completed!"
fi

# --- Remove Configurations ---
if [ "$choice" -eq 4 ]; then
  echo "⚙️ Removing all configurations..."
  
  # Remove dnsmasq
  sudo apt remove --purge -y dnsmasq
  sudo rm -rf /etc/dnsmasq.conf
  echo "✅ dnsmasq configurations removed."
  
  # Remove CoreDNS
  sudo rm -rf /usr/local/bin/coredns
  sudo rm -rf /etc/coredns
  echo "✅ CoreDNS configurations removed."
  
  # Remove Hysteria
  sudo rm -rf /usr/local/bin/hysteria
  sudo rm -rf /etc/hysteria
  echo "✅ Hysteria configurations removed."
fi

# --- Test Server Connection ---
if [ "$choice" -eq 5 ]; then
  echo "⚡ Testing server connection..."
  
  # Simple test to check connectivity
  ping -c 4 google.com
  echo "✅ Connection test completed!"
fi

# End
echo "🌟 DIGITALVORTEX Setup Completed!"
echo "🚀 Your system is ready to bypass DNS filtering and use Hysteria VPN for full internet access."
