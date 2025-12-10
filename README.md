# Postinstall Debian 13 (CLI Master VM)

## Pré-requis
Une machine sous Debian 13.
Être connecté en tant que root (ou avoir les droits sudo).
```bash
apt-get update -y
apt-get install ssh -y
```
## Exécution du script
```bash
bash -c "$(wget -qO- https://raw.githubusercontent.com/Itsei/postinstall_debian/main/postinstall.sh)"
```
## Fonctionnalités
