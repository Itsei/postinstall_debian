#!/bin/bash
set -e

echo "=========================================="
echo "  Post-install Debian 13 (CLI Only)"
echo "=========================================="

echo "[1/8] Mise à jour du système..."
apt update -y && apt upgrade -y

echo "[2/8] Installation des outils CLI..."
apt install -y ssh zip unzip nmap locate ncdu curl git screen dnsutils net-tools sudo lynx
updatedb

echo "[3/8] Installation Samba + Winbind..."
apt install -y samba winbind

echo "[4/8] Configuration nsswitch.conf..."
sed -i 's/^hosts:.*/hosts: files dns wins/' /etc/nsswitch.conf

echo "[5/8] Activation des couleurs du Bash root..."
sed -i '9,13s/^#//' /root/.bashrc

echo "[6/8] Configuration réseau (IP statique)"
read -p "Interface réseau [ens33] : " IFACE
IFACE=${IFACE:-ens33}
read -p "Adresse IP : " IPADDR
read -p "Masque réseau : " NETMASK
read -p "Passerelle : " GATEWAY

cat <<EOF >/etc/network/interfaces
auto $IFACE
iface $IFACE inet static
    address $IPADDR
    netmask $NETMASK
    gateway $GATEWAY
EOF

echo "[7/8] Configuration DNS"
read -p "DNS primaire : " DNS
cat <<EOF >/etc/resolv.conf
nameserver $DNS
EOF

echo "[8/8] Configuration hostname..."
hostnamectl set-hostname debian

echo "[9/8] Installation Webmin..."
curl -o /root/webmin-setup-repo.sh https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh
sh /root/webmin-setup-repo.sh
apt install -y webmin --install-recommends

echo
echo "=========================================="
echo "  POSTINSTALL TERMINÉ"
echo "=========================================="
echo "IP configurée     : $IPADDR"
echo "DNS configuré     : $DNS"
echo "Interface réseau  : $IFACE"
echo "→ Redémarrer la machine avec 'reboot'"
echo "=========================================="
