#!/bin/bash
set -euo pipefail

# Configuration par défaut (master VM clonable)
DEFAULT_IFACE="ens33"
DEFAULT_DNS="8.8.8.8"
DEFAULT_HOSTNAME="debian-master"

# Arguments positionnels (tous optionnels)
IFACE="${1:-$DEFAULT_IFACE}"
IPADDR="${2:-}"
NETMASK="${3:-}"
GATEWAY="${4:-}"
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
    openssh-server zip unzip nmap mlocate ncdu curl git screen \
    dnsutils net-tools sudo lynx ca-certificates

updatedb

echo "[3/9] Installation Samba + Winbind..."
apt install -y samba winbind

echo "[4/9] Configuration résolution noms (WINS)..."
if grep -q "^hosts:" /etc/nsswitch.conf; then
    sed -i 's/^hosts:.*/hosts: files dns wins/' /etc/nsswitch.conf
else
    echo 'hosts: files dns wins' >> /etc/nsswitch.conf
fi

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
[[ -f /etc/resolv.conf ]] && cp /etc/resolv.conf /etc/resolv.conf.bak
cat > /etc/resolv.conf <<EOF
nameserver $DNS
search lan
EOF

echo "[8/9] Hostname..."
hostnamectl set-hostname "$HOSTNAME"
echo "$HOSTNAME" > /etc/hostname

echo "[9/9] Installation Webmin..."
if ! dpkg -l | awk '{print $2}' | grep -qx "webmin"; then
    curl -sS -o /root/webmin-setup-repo.sh \
        https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh
    bash /root/webmin-setup-repo.sh >/dev/null
    apt update -y
    apt install -y webmin --install-recommends
    rm -f /root/webmin-setup-repo.sh
else
    echo "Webmin déjà présent"
fi

echo
echo "=========================================="
echo "     POSTINSTALL TERMINÉ AVEC SUCCÈS"
echo "=========================================="
[[ -n "$IPADDR" ]] && echo "IP configurée : $IPADDR"
echo "DNS           : $DNS"
echo "Interface     : $IFACE"
echo "Hostname      : $HOSTNAME"
echo
echo "Redémarrez maintenant : reboot"
echo "=========================================="
