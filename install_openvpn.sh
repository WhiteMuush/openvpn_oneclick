#!/bin/bash

set -e  # Stoppe le script en cas d'erreur

# Variables
SERVER_NAME="myvpn"
CLIENT_NAME="client"
VPN_PORT=1194
VPN_PROTOCOL="udp"
VPN_NET="10.8.0.0"
VPN_MASK="255.255.255.0"
EASYRSA_DIR="/etc/openvpn/easy-rsa"

# Mise a jour et installation
apt update && apt upgrade -y
apt install -y openvpn easy-rsa iptables-persistent curl

# Configuration Easy-RSA
make-cadir "$EASYRSA_DIR"
cd "$EASYRSA_DIR"
./easyrsa init-pki
echo | ./easyrsa build-ca nopass
./easyrsa gen-dh
./easyrsa build-server-full "$SERVER_NAME" nopass
./easyrsa build-client-full "$CLIENT_NAME" nopass
./easyrsa gen-crl

# Copier les fichiers necessaires
cp pki/ca.crt pki/private/"$SERVER_NAME".key pki/issued/"$SERVER_NAME".crt pki/dh.pem /etc/openvpn
cp pki/crl.pem /etc/openvpn/crl.pem
chown nobody:nogroup /etc/openvpn/crl.pem

# Config serveur
cat > /etc/openvpn/server.conf <<EOF
port $VPN_PORT
proto $VPN_PROTOCOL
dev tun
ca ca.crt
cert $SERVER_NAME.crt
key $SERVER_NAME.key
dh dh.pem
crl-verify crl.pem
server $VPN_NET $VPN_MASK
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 1.1.1.1"
keepalive 10 120
cipher AES-256-CBC
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
verb 3
EOF

# Activer IP forwarding
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p

# Configuration du pare-feu
iptables -t nat -A POSTROUTING -s "$VPN_NET"/24 -o eth0 -j MASQUERADE
iptables-save > /etc/iptables/rules.v4

# Activer OpenVPN au demarrage
systemctl enable openvpn@server
systemctl start openvpn@server

# Generation du fichier .ovpn client 
mkdir -p ~/client-configs
cat > ~/client-configs/base.conf <<EOF
client
dev tun
proto $VPN_PROTOCOL
remote $(curl -s ifconfig.me) $VPN_PORT
resolv-retry infinite
nobind
persist-key
persist-tun
cipher AES-256-CBC
verb 3
<ca>
$(cat $EASYRSA_DIR/pki/ca.crt)
</ca>
<cert>
$(cat $EASYRSA_DIR/pki/issued/$CLIENT_NAME.crt)
</cert>
<key>
$(cat $EASYRSA_DIR/pki/private/$CLIENT_NAME.key)
</key>
EOF

echo -e "\neConfiguration terminee. Le fichier client est ici : ~/client-configs/base.conf"

