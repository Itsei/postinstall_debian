#!/bin/bash
set -euo pipefail

DEFAULT_IFACE="ens33"
DEFAULT_DNS="8.8.8.8"
DEFAULT_HOSTNAME="debian-master"

# Arguments à passer pour IP statique et DNS
IFACE="${1:-$DEFAULT_IFACE}"
IPADDR="${2:-}"       # Exemple: 192.168.1.50
NETMASK="${3:-}"      # Exemple: 255.255.255.0
GATEWAY="${4:-}"      # Exemple: 192.168.1.1
DNS="${5:-$DEFAULT_DNS}"
HOSTNAME="${6:-$DEFAULT_HOSTNAME}"

clear
echo "=========================================="
echo "   POSTINSTALL DEBIAN 13 CLI MASTER"
echo "=========================================="

echo "[1/9] Mise à jour complète du système..."
apt update -y && apt full-upgrade -y

echo "[2/9] Installation des outils essentiels..."
apt install -y \
    openssh-server zip unzip nmap ncdu wget git screen \
    bind9-dnsutils net-tools sudo lynx ca-certificates

echo "[3/9] Installation Samba + Winbind..."
apt install -y samba winbind

echo "[4/9] Configuration résolution noms (WINS)..."
grep -q "^hosts:.*wins" /etc/nsswitch.conf || \
    sed -i 's/^hosts:.*/hosts: files dns wins/' /etc/nsswitch.conf

echo "[5/9] Activation couleurs Bash root..."
sed -i '9,13s/^#//' /root/.bashrc || true

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
    echo "Aucun paramètre IP → DHCP conservé"
fi

echo "[7/9] Configuration DNS..."
[[ -f /etc/resolv.conf ]] && cp -a /etc/resolv.conf /etc/resolv.conf.bak
cat > /etc/resolv.conf <<EOF
nameserver $DNS
search lan
EOF

echo "[8/9] Hostname..."
hostnamectl set-hostname "$HOSTNAME"
echo "$HOSTNAME" > /etc/hostname

echo "[9/9] Installation Webmin..."
if ! dpkg -l | grep -q "^ii  webmin "; then
    apt install -y curl
    curl -sS -o /tmp/webmin-setup-repo.sh https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh
    sh /tmp/webmin-setup-repo.sh
    apt update -y
    DEBIAN_FRONTEND=noninteractive apt install -y webmin --install-recommends
    rm -f /tmp/webmin-setup-repo.sh
else
    echo "Webmin déjà présent"
fi

echo
echo "=========================================="
echo "     POSTINSTALL TERMINÉ AVEC SUCCÈS"
echo "=========================================="
[[ -n "$IPADDR" ]] && echo "IP configurée     : $IPADDR"
echo "Netmask           : $NETMASK"
echo "Gateway           : $GATEWAY"
echo "DNS               : $DNS"
echo "Interface         : $IFACE"
echo "Hostname          : $HOSTNAME"
echo
echo "Redémarrez maintenant : reboot"
echo "=========================================="
