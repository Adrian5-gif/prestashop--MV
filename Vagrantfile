# -*- mode: ruby -*-
# vi: set ft=ruby :

# Implantación de PrestaShop en una máquina virtual
# Una sola máquina con la pila LAMP, phpMyAdmin, HTTPS y PrestaShop

Vagrant.configure("2") do |config|

  # Debian 12 (Bookworm)
  config.vm.box = "debian/bookworm64"

  config.vm.hostname = "AdrianRiosPrestaShop"

  # Puertos 80 y 443 de mi PC -> puertos 80 y 443 de la máquina
  config.vm.network "forwarded_port", guest: 80,  host: 80
  config.vm.network "forwarded_port", guest: 443, host: 443

  config.vm.provider "virtualbox" do |vb|
    vb.name   = "AdrianRiosPrestaShop"
    vb.memory = 2048   # PrestaShop necesita al menos 2 GB de RAM
  end

  # Orden de instalación
  config.vm.provision "lamp",       type: "shell", path: "scripts/install_lamp.sh"
  config.vm.provision "phpmyadmin", type: "shell", path: "scripts/install_phpmyadmin.sh"
  config.vm.provision "https",      type: "shell", path: "scripts/setup_letsencrypt_https.sh"
  config.vm.provision "prestashop", type: "shell", path: "scripts/deploy_prestashop.sh"

end
