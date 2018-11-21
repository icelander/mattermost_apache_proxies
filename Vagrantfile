# -*- mode: ruby -*-
# vi: set ft=ruby :

MYSQL_ROOT_PASSWORD = 'mysql_root_password'
MATTERMOST_PASSWORD = 'really_secure_password'

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-16.04"

  config.vm.define "apache" do |apache|
    apache.vm.hostname = 'www.bandicootsrus.com'
    apache.vm.network "private_network", ip: "192.168.33.101"
    apache.vm.network "public_network", ip: "192.168.0.99"

    setup_script = File.read('apache_setup.sh')
    apache.vm.provision :shell, inline: setup_script, run: 'once'
  end

  config.vm.define "mattermost" do |mattermost|
  	mattermost.vm.network "forwarded_port", guest: 8065, host: 8065
  	mattermost.vm.network "forwarded_port", guest: 3306, host: 13306
    mattermost.vm.network "forwarded_port", guest: 8443, host: 8443
    mattermost.vm.network "private_network", ip: "192.168.33.102"
  	
  	mattermost.vm.hostname = 'mattermost'

  	setup_script = File.read('setup.sh')

  	setup_script.gsub!('#MATTERMOST_PASSWORD', MATTERMOST_PASSWORD)
  	setup_script.gsub!('#MYSQL_ROOT_PASSWORD', MYSQL_ROOT_PASSWORD)
  	
  	mattermost.vm.provision :shell, inline: setup_script, run: 'once'
  end
  
end
