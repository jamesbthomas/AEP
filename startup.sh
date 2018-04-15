#!/bin/bash

# Load approved private keys from gitwe/keys into the gitweb user's list of authorized keys
if [ "$(ls -A /gitweb/keys/)" ]; then
	cd /home/gitweb
	cat /gitweb/keys/*.pub > .ssh/authorized_keys
	chown -R gitweb:gitweb .ssh
	chmod 700 .ssh
	chmod -R 600 .ssh/*
fi

# Start the SSH Daemon for Git over SSH
/usr/sbin/sshd -D &

# set git configs and build an RSA key
echo -e "/home/gitweb/.ssh/id_rsa\n\n\n" | ssh-keygen -t rsa -b 4096 -C "gitweb@gitweb.com" &> /dev/null
cat /home/gitweb/.ssh/id_rsa.pub >> /home/gitweb/.ssh/authorized_keys
chown -R gitweb:gitweb /home/gitweb/.ssh
eval `ssh-agent -s` &> /dev/null
ssh-add /home/gitweb/.ssh/id_rsa &> /dev/null

chown -R gitweb /gitweb.git

cd /home/gitweb
chown -R gitweb /home/gitweb > /dev/null
ssh -o StrictHostKeyChecking=no gitweb@localhost -p 2222 &> /dev/null
git clone ssh://gitweb@localhost:2222/gitweb.git &> /dev/null

mv gitweb repo
cd repo

while [ 1 ];
do
	echo $(ls) > file.txt
	nc -l -p 4443 -w 5 < file.txt 2> /dev/null
done
