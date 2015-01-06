#!/usr/bin/env bash

# IMPORTANT: When this script is invoked as part of VAGRANT UP (i.e. as specified 
# via  Vagrantfile), it executes while being logged in as root (and $HOME is /root). 
# However, the VAGRANT SSH command logs you in as "vagrant" and $HOME is /home/vagrant.

# This script is idempotent. There is no harm is running it multiple times.

echo "==========  Starting Bootstrap.sh  ==========" &>> /vagrant/bootstrap.log

######################################################   Linux Software Installs (as root)

sudo apt-get update 2>> /vagrant/bootstrap.log

# Install the 3 version-control systems
sudo apt-get install -y git mercurial bzr 2>> /vagrant/bootstrap.log

# Next, install a specific version of Go
cd ~
if [ ! -d "/usr/local/go" ]; then
	echo "Installing Go" &>> /vagrant/bootstrap.log
	wget -q https://storage.googleapis.com/golang/go1.4.linux-386.tar.gz 2>> /vagrant/bootstrap.log
	tar -C /usr/local -xzf go1.4.linux-386.tar.gz 2>> /vagrant/bootstrap.log
fi


######################################################   User-Specific Config (as vagrant)
if [ "$EUID" -e 0 ]; then 
	echo "Switching from root user to vagrant user" &>> /vagrant/bootstrap.log
	su -l vagrant
fi

echo "HOME = $HOME" &>> /vagrant/bootstrap.log

if [ -f "/vagrant/bash_aliases" ]; then
	echo "bash_aliases exists" &>> /vagrant/bootstrap.log
	if ! [ -f "$HOME/.bash_aliases" ]; then
		echo "Copying bash_aliases as ~/.bash_aliases" &>> /vagrant/bootstrap.log
		sudo cp /vagrant/bash_aliases $HOME/.bash_aliases 2>> /vagrant/bootstrap.log
		sudo chmod 644 $HOME/.bash_aliases
	fi
	if [ -f "$HOME/.bash_aliases" ]; then
		source ~/.bash_aliases
	else
		echo "ERROR: FAILED TO COPY bash_aliases as ~/.bash_aliases" &>> /vagrant/bootstrap.log
	fi
fi

if [ -f "/vagrant/local_config.sh" ]; then
	echo "local_config.sh exists" &>> /vagrant/bootstrap.log
	source /vagrant/local_config.sh
fi

######################################################   Version Control Configuration


echo "VC_NAME = $VC_NAME" &>> /vagrant/bootstrap.log
echo "VC_EMAIL = $VC_EMAIL" &>> /vagrant/bootstrap.log
echo "GITHUB_APP_TOKEN = $GITHUB_APP_TOKEN" &>> /vagrant/bootstrap.log

git config --global user.name "$VC_NAME"
git config --global user.email $VC_EMAIL
bzr whoami "$VC_NAME <$VC_EMAIL>"
# TODO Create a file called ~/.hgrc with Hg settings, including username=John Doe <johndoe@example.com> (under the [ui] section)
if ! [ -f "$HOME/.netrc" ]; then
	echo "~/.netrc does not already exist. Creating it now." &>> /vagrant/bootstrap.log
	sudo echo "machine github.com login $GITHUB_APP_TOKEN" > $HOME/.netrc
	if ! [ -f "$HOME/.netrc" ]; then
		echo "ERROR: FAILED TO CREATE ~/.netrc" &>> /vagrant/bootstrap.log
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
