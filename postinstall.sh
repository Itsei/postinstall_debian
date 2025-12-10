#!/bin/bash
set -e

echo "=========================================="
echo "  POSTINSTALL DEBIAN 13 CLI"
echo "=========================================="

echo "[1/9] Mise à jour..."
apt update -y && apt upgrade -y

echo "[2/9] Installation outils..."
apt install -y ssh zip unzip nmap locate ncdu curl git screen dnsutils net-tools sudo lynx
updatedb

echo "[3/9] Installation Samba + Winbind..."
apt install -y samba winbind

echo "[4/9] Configuration nsswitch.conf..."
sed -i 's/^hosts:.*/hosts: files dns wins/' /etc/nsswitch.conf

echo "[5/9] Couleurs Bash root..."
sed -i '9,13s/^#//' /root/.bashrc

echo "[6/9] Configuration IP statique"
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

echo "[7/9] Configuration DNS"
read -p "DNS primaire : " DNS
cat <<EOF >/etc/resolv.conf
nameserver $DNS
EOF

echo "[8/9] Hostname..."
hostnamectl set-hostname debian

echo "[9/9] Installation Webmin..."
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
echo "→ Redémarrez la machine avec 'reboot'"
echo "=========================================="

