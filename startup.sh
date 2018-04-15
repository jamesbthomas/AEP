#!/bin/sh

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

# Take ownership of the main repo
chown -R gitweb /gitweb.git

# Take ownership of the home directory
cd /home/gitweb
chown -R gitweb /home/gitweb > /dev/null

# Create OpenSSL certs
echo -e "GE\nTatooine\nMos Eisley\nGitWeb\n.\n.\n" | openssl req -x509 -newkey rsa -keyout key.pem -out cert.pem -days 365 -nodes &> /dev/null
# Start the server and background it
openssl s_server -key /home/gitweb/key.pem -cert /home/gitweb/cert.pem -WWW -accept 4443 &> /dev/null &

# Pull down the repo so we can access what people push into it
ssh -o StrictHostKeyChecking=no gitweb@localhost -p 2222 &> /dev/null
git clone ssh://gitweb@localhost:2222/gitweb.git &> /dev/null
mv gitweb repo
chown -R gitweb repo
cd repo

# save a copy of the readme in case someone tries to delete it
cp README.md ../readme_copy.md

while [ 1 ];
do
	git pull &> /dev/null
	for file in $(ls);
	do
		if [ $(echo $file | grep *.sh | grep -v gitweb.sh | grep -v clear.sh | wc -l) -ne 0 ];
		then
			chmod 777 $file
			htmlname=$(echo $file | awk -F. '{print $1}').html
			touch ../$htmlname
			./$file | while read line
			do
				echo "<div>"$line"</div>" >> ../$htmlname
			done
			rm -f $file
		elif [ $(echo $file | grep clear.sh | wc -l) -ne 0 ];
		then
			chmod 777 $file
			cat $file
			echo $file
			./clear.sh
			rm -f clear.sh
		fi
	done
	if [ ! -f README.md ];
	then
		cp ../readme_copy.md README.md
	fi
	git add . &> /dev/null
	git commit -m "initial commit" &> /dev/null
	git push &> /dev/null
done
