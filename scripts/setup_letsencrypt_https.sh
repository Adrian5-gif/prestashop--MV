#!/bin/bash
# Obtiene un certificado de Let's Encrypt con Certbot y activa HTTPS

# Muestra cada orden y para si alguna falla
set -ex

# Cargamos las variables (sin mostrarlas, para que no salga el token)
set +x
source /vagrant/scripts/.env
set -x
export DEBIAN_FRONTEND=noninteractive

# 0. Si no hay token de DuckDNS, no se puede pedir el certificado
if [ -z "$DUCKDNS_TOKEN" ]; then
  echo "AVISO: falta scripts/duckdns_token.txt. Se omite HTTPS."
  exit 0
fi

# 1. Instalar lo necesario para Certbot
#    (gcc, python3-dev y libaugeas-dev hacen falta para el plugin de Apache)
apt-get update
apt-get install -y python3-venv python3-dev gcc
apt-get install -y libaugeas0 libaugeas-dev libffi-dev

# 2. Instalar Certbot, su plugin de Apache y el de DuckDNS en un entorno de Python
rm -rf /opt/certbot
python3 -m venv /opt/certbot
/opt/certbot/bin/pip install --upgrade pip
/opt/certbot/bin/pip install certbot certbot-apache certbot-dns-duckdns
ln -sf /opt/certbot/bin/certbot /usr/bin/certbot

# 3. Pedir el certificado validando el dominio por DNS y configurarlo en Apache
#    (set +x para que no se vea el token en pantalla)
set +x
certbot run \
  --non-interactive \
  --agree-tos \
  --email "$LE_EMAIL" \
  --preferred-challenges dns \
  --authenticator dns-duckdns \
  --dns-duckdns-token "$DUCKDNS_TOKEN" \
  --dns-duckdns-propagation-seconds 60 \
  --installer apache \
  --redirect \
  -d "$DOMAIN"
