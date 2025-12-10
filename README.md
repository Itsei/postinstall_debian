# Postinstall Debian 13 (CLI Master VM)

## Pré-requis
```bash
sudo -i
apt update -y
apt install -y openssh-server wget
systemctl enable --now ssh
Exécution du script
bash
Copier le code
sudo bash <(wget -qO- https://github.com/<votre-repo>/raw/main/postinstall.sh)
