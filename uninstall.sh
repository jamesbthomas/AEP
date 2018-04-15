#!/bin/bash
# Bash script designed to uninstall all aspects of the GitWeb server

sudo echo " -- Uninstalling <GitWeb> Server and Repo -- "
echo "Uninstalling OpenSSH Server . . ."
sudo apt-get remove openssh-server -y > /dev/null
echo "  . . . done!"
echo "Removing repo files and SSH keys . . ."
sudo rm -rf /srv/git &> /dev/null
ssh-keygen -R gitweb &> /dev/null
rm -f ~/.ssh/known_hosts.old &> /dev/null
echo "  . . . done!"
echo "Deleting the gitweb user . . ."
sudo userdel -r gitweb &> /dev/null
echo "  . . . done!"
echo "Bye!"
