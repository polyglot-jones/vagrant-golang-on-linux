#!/usr/bin/env bash

echo "==========  Starting Bootstrap.sh"

ls -l /vagrant

if [ -f "/vagrant/profile_continued.sh" ]; then
	echo "==========  profile_continued.sh Exists"
	# chmod 770 "/vagrant/profile_continued.sh"
    . /vagrant/profile_continued.sh
	if ! grep -q GOPATH ~/.profile; then
		sudo cat /vagrant/profile_continued.sh >> ~/.profile
	fi
fi

if [ -f "/vagrant/local_config.sh" ]; then
	echo "==========  local_config.sh Exists"
	# chmod 770 "/vagrant/local_config.sh"
    . /vagrant/local_config.sh
fi

sudo apt-get update

######################################################   Version Control

sudo apt-get install -y git mercurial bzr

echo "VC_NAME = $VC_NAME"
echo "VC_EMAIL = $VC_EMAIL"
echo "GITHUB_APP_TOKEN = $GITHUB_APP_TOKEN"

git config --global user.name "$VC_NAME"
git config --global user.email $VC_EMAIL
bzr whoami "$VC_NAME <$VC_EMAIL>"
# TODO Create a file called ~/.hgrc with Hg settings, including username=John Doe <johndoe@example.com> (under the [ui] section)
if [ ! -f "~/.netrc" ]; then
	echo "~/.netrc does not already exist. Creating it now."
	sudo echo "machine github.com login $GITHUB_APP_TOKEN" > ~/.netrc
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
	wget -q https://storage.googleapis.com/golang/go1.4.linux-386.tar.gz
	tar -C /usr/local -xzf go1.4.linux-386.tar.gz
fi

echo "==========  Ending Bootstrap.sh"
