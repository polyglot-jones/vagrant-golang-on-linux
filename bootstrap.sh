#!/usr/bin/env bash

cp /vagrant/.profile ~/.profile
chmod 777 /vagrant/local_config.sh
. /vagrant/local_config.sh

apt-get update

######################################################   Version Control

apt-get install -y git mercurial bzr

git config --global user.name "$VC_NAME"
git config --global user.email $VC_EMAIL
bzr whoami "$VC_NAME <$VC_EMAIL>"
# TODO Create a file called ~/.hgrc with Hg settings, including username=John Doe <johndoe@example.com> (under the [ui] section)
echo "machine github.com login $GITHUB_APP_KEY" > ~/.netrc

######################################################   Apache Server
apt-get install -y apache2
if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant /var/www
fi

######################################################   Go Lang
cd ~
wget https://storage.googleapis.com/golang/go1.4.linux-386.tar.gz
tar -C /usr/local -xzf go1.4.linux-386.tar.gz
