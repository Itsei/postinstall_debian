#!/bin/bash
set -euo pipefail

# Valeurs par défaut
DEFAULT_IFACE="ens33"
DEFAULT_DNS="8.8.8.8"
DEFAULT_HOSTNAME="changeme"

# --- Paramètres IP statique ---
read -p "Voulez-vous configurer une IP statique ? (y/N) " USE_STATIC
if [[ "$USE_STATIC" =~ ^[Yy]$ ]]; then
    read -p "Interface réseau [${DEFAULT_IFACE}] : " IFACE
    IFACE=${IFACE:-$DEFAULT_IFACE}
    read -p "Adresse IP : " IPADDR
    read -p "Masque réseau : " NETMASK
    read -p "Passerelle : " GATEWAY
else
    IFACE="$DEFAULT_IFACE"
    IPADDR=""
    NETMASK=""
    GATEWAY=""
fi

# DNS et hostname
read -p "DNS [${DEFAULT_DNS}] : " DNS
DNS=${DNS:-$DEFAULT_DNS}

read -p "Hostname [${DEFAULT_HOSTNAME}] : " HOSTNAME
HOSTNAME=${HOSTNAME:-$DEFAULT_HOSTNAME}

clear
echo "=========================================="
echo "   POSTINSTALL DEBIAN 13 CLI MASTER"
echo "=========================================="

# --- 1. Mise à jour ---
echo "[1/9] Mise à jour complète du système..."
apt update -y && apt full-upgrade -y

# --- 2. Installation outils essentiels ---
echo "[2/9] Installation des outils essentiels..."
apt install -y openssh-server zip unzip nmap ncdu wget git screen \
    bind9-dnsutils net-tools sudo lynx ca-certificates

# --- 3. Samba + Winbind ---
echo "[3/9] Installation Samba + Winbind..."
apt install -y samba winbind

# --- 4. Résolution noms WINS ---
echo "[4/9] Configuration résolution noms (WINS)..."
grep -q "^hosts:.*wins" /etc/nsswitch.conf || \
    sed -i 's/^hosts:.*/hosts: files dns wins/' /etc/nsswitch.conf

# --- 5. Couleurs Bash root ---
echo "[5/9] Activation couleurs Bash root..."
LINES=$(wc -l < /root/.bashrc)
if [ "$LINES" -ge 13 ]; then
    sed -i '10,14s/^[[:space:]]*#//' /root/.bashrc
else
    sed -i 's/^[[:space:]]*#\(.*force_color_prompt.*\)/\1/' /root/.bashrc || true
fi

# --- 6. Configuration réseau ---
echo "[6/9] Configuration réseau..."
if [[ -n "$IPADDR" && -n "$NETMASK" && -n "$GATEWAY" ]]; then
    cat > /etc/network/interfaces <<EOF
auto $IFACE
iface $IFACE inet static
    address $IPADDR
    netmask $NETMASK
    gateway $GATEWAY
EOF
    echo "IP statique appliquée : $IPADDR"
else
    echo "DHCP conservé"
fi

# --- 7. Configuration DNS ---
echo "[7/9] Configuration DNS..."
[[ -f /etc/resolv.conf ]] && cp -a /etc/resolv.conf /etc/resolv.conf.bak
cat > /etc/resolv.conf <<EOF
nameserver $DNS
search lan
EOF

# --- 8. Hostname ---
echo "[8/9] Hostname..."
hostnamectl set-hostname "$HOSTNAME"
echo "$HOSTNAME" > /etc/hostname

# --- 9. Installation Webmin ---
echo "[9/9] Installation Webmin..."

apt update -y
apt install -y curl

curl -sS -o webmin-setup-repo.sh https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh

sh webmin-setup-repo.sh --force </dev/null

apt update -y
apt install -y --install-recommends webmin

rm -f webmin-setup-repo.sh
# --- Fin ---
echo
echo "=========================================="
echo "     POSTINSTALL TERMINÉ AVEC SUCCÈS"
echo "=========================================="
[[ -n "$IPADDR" ]] && echo "IP configurée     : $IPADDR"
echo "DNS               : $DNS"
echo "Interface         : $IFACE"
echo "Hostname          : $HOSTNAME"
echo
echo "Redémarrez maintenant : reboot"
echo "=========================================="
