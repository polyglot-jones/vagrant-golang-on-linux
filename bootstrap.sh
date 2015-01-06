#!/usr/bin/env bash

# IMPORTANT: When this script is invoked as part of VAGRANT UP (i.e. as specified 
# via  Vagrantfile), it executes while being logged in as root (and $HOME is /root). 
# However, the VAGRANT SSH command logs you in as "vagrant" and $HOME is /home/vagrant.

# This script is idempotent. There is no harm is running it multiple times.

echo "==========  Starting Bootstrap.sh  ==========" &>> /vagrant/bootstrap.log

######################################################   Linux Software Installs

echo "Pointing apt-get to the PostgreSQL repository." &>> /vagrant/bootstrap.log
echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

echo "Updating apt-get" &>> /vagrant/bootstrap.log
sudo apt-get update 2>> /vagrant/bootstrap.log

echo "Installing the 3 version-control systems" &>> /vagrant/bootstrap.log
sudo apt-get install -y git mercurial bzr 2>> /vagrant/bootstrap.log

echo "Installing PostgreSQL 9.3.x" &>> /vagrant/bootstrap.log
sudo apt-get install -y postgresql-9.3 postgresql-contrib-9.3
echo "Changing Postgre to trust mode (/etc/postgresql/9.3/main/pg_hba.conf)" &>> /vagrant/bootstrap.log
sed -i "s/local\s*all\s*all\s*peer/local all all trust/" /etc/postgresql/9.3/main/pg_hba.conf 2>> /vagrant/bootstrap.log
sudo /etc/init.d/postgresql restart 2>> /vagrant/bootstrap.log
echo "Creating PostgreSQL user 'vagrant' as a superuser and an empty 'vagrant' database." &>> /vagrant/bootstrap.log
sudo -u postgres createuser --superuser vagrant 2>> /vagrant/bootstrap.log
sudo -u postgres createdb --owner=vagrant vagrant 2>> /vagrant/bootstrap.log

cd ~
if [ ! -d "/usr/local/go" ]; then
	echo "Installing the Go language compiler version 1.4" &>> /vagrant/bootstrap.log
	wget -q https://storage.googleapis.com/golang/go1.4.linux-386.tar.gz 2>> /vagrant/bootstrap.log
	tar -C /usr/local -xzf go1.4.linux-386.tar.gz 2>> /vagrant/bootstrap.log
	chown -R vagrant /usr/local/go
fi


######################################################   User-Specific Config
echo "Ensuring that /home/vagrant exists" &>> /vagrant/bootstrap.log
mkdir -p /home/vagrant

if [ -f "/vagrant/bash_aliases" ]; then
	echo "bash_aliases exists" &>> /vagrant/bootstrap.log
	if ! [ -f "/home/vagrant/.bash_aliases" ]; then
		echo "Copying bash_aliases as /home/vagrant/.bash_aliases" &>> /vagrant/bootstrap.log
		sudo cp /vagrant/bash_aliases /home/vagrant/.bash_aliases 2>> /vagrant/bootstrap.log
		sudo chmod 644 /home/vagrant/.bash_aliases
	fi
	if [ -f "/home/vagrant/.bash_aliases" ]; then
		source /home/vagrant/.bash_aliases
	else
		echo "ERROR: FAILED TO COPY bash_aliases as /home/vagrant/.bash_aliases" &>> /vagrant/bootstrap.log
	fi
fi

if [ -f "/vagrant/local_config.sh" ]; then
	echo "Loading local_config.sh" &>> /vagrant/bootstrap.log
	source /vagrant/local_config.sh
fi

######################################################   Version Control Configuration


echo "VC_NAME = $VC_NAME" &>> /vagrant/bootstrap.log
echo "VC_EMAIL = $VC_EMAIL" &>> /vagrant/bootstrap.log
echo "GITHUB_APP_TOKEN = $GITHUB_APP_TOKEN" &>> /vagrant/bootstrap.log

git config --global user.name "$VC_NAME"
git config --global user.email $VC_EMAIL
bzr whoami "$VC_NAME <$VC_EMAIL>"
# TODO Create a file called /home/vagrant/.hgrc with Hg settings, including username=John Doe <johndoe@example.com> (under the [ui] section)
if ! [ -f "/home/vagrant/.netrc" ]; then
	echo "/home/vagrant/.netrc does not already exist. Creating it now." &>> /vagrant/bootstrap.log
	sudo echo "machine github.com login $GITHUB_APP_TOKEN" > /home/vagrant/.netrc
	if ! [ -f "/home/vagrant/.netrc" ]; then
		echo "ERROR: FAILED TO CREATE /home/vagrant/.netrc" &>> /vagrant/bootstrap.log
	fi
fi


######################################################   GoDep
echo "Installing GoDep" &>> /vagrant/bootstrap.log
cd $GOPATH
go get github.com/tools/godep 2>> /vagrant/bootstrap.log
cd src/github.com/tools/godep
go install 2>> /vagrant/bootstrap.log


######################################################   Swagger Generator
echo "Installing the Swagger Generator" &>> /vagrant/bootstrap.log
cd $GOPATH
go get github.com/yvasiyarov/swagger 2>> /vagrant/bootstrap.log
cd src/github.com/yvasiyarov/swagger
go install 2>> /vagrant/bootstrap.log


echo "==========  Ending Bootstrap.sh  ==========" &>> /vagrant/bootstrap.log
