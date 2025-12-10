# Postinstall Debian 13 (CLI Master VM)

## Pré-requis
root
```bash
apt-get update -y
apt-get install ssh -y
```
## Exécution du script
```bash
bash -c "$(wget -qO- https://raw.githubusercontent.com/Itsei/postinstall_debian/main/postinstall.sh)"
```
