#!/bin/bash
# Instala phpMyAdmin para gestionar la base de datos desde el navegador

# Muestra cada orden y para si alguna falla
set -ex

# Cargamos las variables
source /vagrant/scripts/.env
export DEBIAN_FRONTEND=noninteractive

# 1. Contestar antes las preguntas que hace el instalador de phpMyAdmin
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true"             | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PMA_PASSWORD"     | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PMA_PASSWORD" | debconf-set-selections

# 2. Instalar phpMyAdmin
apt-get install -y phpmyadmin

# 3. Crear un usuario para entrar en phpMyAdmin
mysql -u root <<EOF
DROP USER IF EXISTS '$PMA_USER'@'localhost';
CREATE USER '$PMA_USER'@'localhost' IDENTIFIED BY '$PMA_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO '$PMA_USER'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

# 4. Reiniciar Apache
systemctl restart apache2
