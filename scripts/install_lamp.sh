#!/bin/bash
# Instala la pila LAMP con todo lo que necesita PrestaShop

# Muestra cada orden y para si alguna falla
set -ex

# Cargamos las variables
source /vagrant/scripts/.env
export DEBIAN_FRONTEND=noninteractive

# 1. Actualizar la lista de paquetes
apt-get update

# 2. Instalar Apache, MariaDB, PHP y las extensiones que pide PrestaShop
apt-get install -y apache2 mariadb-server unzip curl \
  php libapache2-mod-php php-mysql php-cli \
  php-curl php-gd php-intl php-mbstring php-xml php-zip \
  php-bcmath php-imagick php-memcached

# 3. Activar los módulos de Apache que recomienda PrestaShop
a2enmod rewrite
a2enmod headers
a2enmod env

# 4. Copiar el VirtualHost (permite usar .htaccess y pone el dominio)
cp /vagrant/conf/000-default.conf /etc/apache2/sites-available/000-default.conf
sed -i "s/DOMINIO/$DOMAIN/" /etc/apache2/sites-available/000-default.conf

# 5. Ajustar php.ini con los valores que recomienda PrestaShop
PHP_INI=$(ls /etc/php/*/apache2/php.ini)
sed -i "s/^;\?memory_limit.*/memory_limit = 256M/"               $PHP_INI
sed -i "s/^;\?max_input_vars.*/max_input_vars = 5000/"           $PHP_INI
sed -i "s/^;\?post_max_size.*/post_max_size = 128M/"             $PHP_INI
sed -i "s/^;\?upload_max_filesize.*/upload_max_filesize = 128M/" $PHP_INI
sed -i "s/^;\?expose_php.*/expose_php = Off/"                    $PHP_INI

# 6. Reiniciar Apache para aplicar los cambios
systemctl restart apache2
