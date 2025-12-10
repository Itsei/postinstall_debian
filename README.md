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
Le script automatise la configuration initiale d'une Debian 13 CLI :

1. **Mise à jour complète du système**
2. **Installation des outils essentiels**  
   - `openssh-server`, `zip/unzip`, `nmap`, `ncdu`, `wget`, `git`, `screen`, `dnsutils`, `net-tools`, `sudo`, `lynx`, `ca-certificates`
3. **Installation Samba + Winbind** pour la compatibilité réseau Windows
4. **Configuration de la résolution WINS** (modifie `/etc/nsswitch.conf`)
5. **Activation des couleurs dans le Bash du root**
6. **Configuration réseau**  
   - Option d’IP statique avec adresse IP, masque et passerelle
7. **Configuration DNS** (modifie `/etc/resolv.conf`)
8. **Définition du hostname**
9. **Installation silencieuse de Webmin** (serveur web d’administration)

## Utilisation

Suivez les invites pour :

- Choisir une IP statique ou DHCP
- Renseigner l’adresse IP, le masque, la passerelle et le DNS
- Définir le hostname de la machine

Après l’exécution, le script affiche un récapitulatif :

- **IP configurée**
- **DNS**
- **Interface réseau**
- **Hostname**
