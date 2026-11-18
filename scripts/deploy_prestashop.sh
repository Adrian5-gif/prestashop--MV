#!/bin/bash
# Descarga e instala PrestaShop desde la línea de comandos (CLI)

# Muestra cada orden y para si alguna falla
set -ex

# Cargamos las variables
set +x
source /vagrant/scripts/.env
set -x
export DEBIAN_FRONTEND=noninteractive

# 1. Crear la base de datos y el usuario de PrestaShop
mysql -u root <<EOF
DROP DATABASE IF EXISTS $PS_DB_NAME;
CREATE DATABASE $PS_DB_NAME CHARSET utf8mb4;
DROP USER IF EXISTS '$PS_DB_USER'@'localhost';
CREATE USER '$PS_DB_USER'@'localhost' IDENTIFIED BY '$PS_DB_PASSWORD';
GRANT ALL PRIVILEGES ON $PS_DB_NAME.* TO '$PS_DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

# 2. Vaciar /var/www/html
rm -rf /var/www/html/*
rm -rf /var/www/html/.htaccess

# 3. Descargar PrestaShop
rm -rf /tmp/prestashop
mkdir -p /tmp/prestashop
curl -L -o /tmp/prestashop/prestashop-classic.zip "$PS_URL"

# 4. Descomprimir. El zip trae dentro otro zip (prestashop.zip) con la aplicación
unzip -q /tmp/prestashop/prestashop-classic.zip -d /tmp/prestashop
unzip -q /tmp/prestashop/prestashop.zip -d /var/www/html

# 5. Descargar PhpPsInfo para comprobar que el servidor cumple los requisitos
curl -L -o /var/www/html/phppsinfo.php \
  https://raw.githubusercontent.com/PrestaShop/php-ps-info/master/phppsinfo.php

# 6. Dar los ficheros al usuario de Apache
chown -R www-data:www-data /var/www/html

# 7. Instalar PrestaShop desde la línea de comandos
cd /var/www/html/install
sudo -u www-data php index_cli.php \
  --domain="$DOMAIN" \
  --db_server=localhost \
  --db_name="$PS_DB_NAME" \
  --db_user="$PS_DB_USER" \
  --db_password="$PS_DB_PASSWORD" \
  --prefix=ps_ \
  --name="$PS_SHOP_NAME" \
  --email="$PS_ADMIN_EMAIL" \
  --password="$PS_ADMIN_PASSWORD" \
  --language="$PS_LANGUAGE" \
  --country="$PS_COUNTRY" \
  --ssl=1

# 8. No hace falta borrar install ni renombrar admin: el instalador de PrestaShop 9 ya lo hace solo

# 9. Reiniciar Apache
systemctl restart apache2
