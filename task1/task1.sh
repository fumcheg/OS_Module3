#!/bin/bash
REPO_EXISTS=$(cat /etc/apt/sources.list /etc/apt/sources.list.d/* | grep -i "^deb .*$(lsb_release -sc)-backports")

if [ $? -gt 0 ]
then
	echo "##### Backspots repository was not found, adding it to the list..."
	# run add-apt-repository, suppress update
	add-apt-repository -n -y "deb http://archive.ubuntu.com/ubuntu/ $(lsb_release -sc)-backports main restricted universe multiverse"
else
	echo "##### Backspots repository is already in list:"
	echo $REPO_EXISTS
fi

# run apt update
echo "##### Updating apt..."
apt update

PKGS_TO_INSTALL=("apache2" "python3.12" "ssh")
for PKG in ${PKGS_TO_INSTALL[@]};
do
	# check if package is installes otherwise install it, mute stderr for dpkg-querry
	INSTALLED=$(dpkg -s "$PKG" 2>/dev/null | grep "install ok installed") 
	if [[ -z $INSTALLED ]]
	then
		echo "##### Installing package [$PKG]..."
		apt install -y $PKG
	else
		echo "##### Package is already installed [$PKG]"
	fi
done

sleep 1

# change some default settings for ssh: disable password auth and enable key usage
echo "##### Configuring /etc/ssh/sshd_config..."
sed -i -E 's/(^|^#.*)PubkeyAuthentication (no|yes)/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i -E 's/(^|^#.*)PasswordAuthentication (no|yes)/PasswordAuthentication no/' /etc/ssh/sshd_config

# add firewall rules
echo "##### Adding firewall rules..."
ufw allow http
ufw allow https
ufw allow ssh

# restart (or start) ssh service
echo "##### Restarting sshd..."
systemctl restart sshd
