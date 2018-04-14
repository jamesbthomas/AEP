#!/bin/bash
# Bash script to install all the necessary components of the gitweb server

# Ensure we have root privileges
if ($(echo $EUID) != 0)
then
	sudo echo "Now running with root privileges"
fi

# Capture the user name of the person who ran this script
run_user=$USER

# Create a user for the server and an ssh directory for it
# gitweb default password is gitweb
echo "Creating user gitweb with default password gitweb..."
sudo adduser gitweb --gecos "gitweb,none,none,none" --disabled-password
echo "gitweb:gitweb" | sudo chpasswd
echo gitweb | sudo -u gitweb -S mkdir /home/gitweb/.ssh
sudo -u gitweb chmod 700 /home/gitweb/.ssh

exit
echo "failed"
# Add the SSH keys of the user who ran this script to the authorized_keys file
for pub in $(ls /home/$run_user/.ssh/*.pub)
do
	cat $pub > ./$(echo $pub | awk -F"/" '{print $5}')
done

# Create the remote repository
mkdir /srv/git/gitweb.git
cd /srv/git/gitweb.git
git init --bare

# Clean up
sudo userdel -r gitweb
rm -rf /srv/*
