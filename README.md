# OpenVPN One-Click Installer

Ce script Bash permet d’installer et de configurer automatiquement un serveur OpenVPN sur une machine Ubuntu/Debian.

## Fonctionnalités

- Installation automatique d’OpenVPN, Easy-RSA et des dépendances
- Génération des certificats serveur et client
- Configuration du serveur OpenVPN (`/etc/openvpn/server.conf`)
- Activation du routage IP et configuration du pare-feu (iptables)
- Génération d’un fichier client `.ovpn` prêt à l’emploi

## Prérequis

- Serveur Ubuntu/Debian avec accès root
- Port UDP 1194 ouvert (modifiable dans le script)
- Interface réseau principale nommée `eth0` (à adapter si besoin)
- WSL non testé et non testé sous Windows 10/11.

## Utilisation

1. Téléchargez le script sur votre serveur :
    ```bash
    wget https://votre-url/script.sh -O openvpn_oneclick.sh
    chmod +x openvpn_oneclick.sh
    ```

2. Exécutez-le en tant que root :
    ```bash
    sudo ./openvpn_oneclick.sh
    ```

3. À la fin, récupérez le fichier client généré :
    ```
    ~/client-configs/base.conf
    ```
    Renommez-le en `.ovpn` et importez-le dans votre client OpenVPN.

## Personnalisation

Modifiez les variables en haut du script pour changer le nom du serveur, du client, le port, le protocole, etc.

## Sécurité

- Les certificats sont générés sans mot de passe pour simplifier l’usage (à adapter selon vos besoins).
- Pensez à sauvegarder vos clés et certificats.

## Avertissement

Ce script est destiné à un usage personnel ou pour des tests. Pour une utilisation en production, adaptez la configuration à vos besoins de sécurité.

---
## OPENVPN DOC

https://openvpn.net/community-resources/reference-manual-for-openvpn-2-4/

*Script fourni à titre d’exemple, sans garantie.*
