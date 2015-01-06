#!/usr/bin/env bash

# This script is idempotent. There is no harm is running it multiple times.

echo "==========  Starting Bootstrap.sh  ==========" &>> /vagrant/bootstrap.log

ls -l /vagrant

if [ -f "/vagrant/profile_continued.sh" ]; then
	echo "profile_continued.sh exists" &>> /vagrant/bootstrap.log
	# chmod 770 "/vagrant/profile_continued.sh"
    source /vagrant/profile_continued.sh
	if ! grep -q GOPATH ~/.profile; then
		echo "Appending profile_continued.sh to ~/.profile" &>> /vagrant/bootstrap.log
		sudo cat /vagrant/profile_continued.sh >> ~/.profile 2>> /vagrant/bootstrap.log
	fi
fi

if [ -f "/vagrant/local_config.sh" ]; then
	echo "local_config.sh exists" &>> /vagrant/bootstrap.log
	# chmod 770 "/vagrant/local_config.sh"
    source /vagrant/local_config.sh
fi

sudo apt-get update 2>> /vagrant/bootstrap.log

######################################################   Version Control

sudo apt-get install -y git mercurial bzr 2>> /vagrant/bootstrap.log

echo "VC_NAME = $VC_NAME" &>> /vagrant/bootstrap.log
echo "VC_EMAIL = $VC_EMAIL" &>> /vagrant/bootstrap.log
echo "GITHUB_APP_TOKEN = $GITHUB_APP_TOKEN" &>> /vagrant/bootstrap.log

git config --global user.name "$VC_NAME"
git config --global user.email $VC_EMAIL
bzr whoami "$VC_NAME <$VC_EMAIL>"
# TODO Create a file called ~/.hgrc with Hg settings, including username=John Doe <johndoe@example.com> (under the [ui] section)
if [ ! -f "~/.netrc" ]; then
	echo "~/.netrc does not already exist. Creating it now." &>> /vagrant/bootstrap.log
	sudo echo "machine github.com login $GITHUB_APP_TOKEN" > ~/.netrc 2>> /vagrant/bootstrap.log
fi

######################################################   Apache Server
# sudo apt-get install -y apache2
# if ! [ -L /var/www ]; then
#   rm -rf /var/www
#   ln -fs /vagrant /var/www
# fi

######################################################   Go Lang
cd ~
if [ ! -d "/usr/local/go" ]; then
	echo "Installing Go" &>> /vagrant/bootstrap.log
	wget -q https://storage.googleapis.com/golang/go1.4.linux-386.tar.gz 2>> /vagrant/bootstrap.log
	tar -C /usr/local -xzf go1.4.linux-386.tar.gz 2>> /vagrant/bootstrap.log
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
