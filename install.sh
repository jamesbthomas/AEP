#!/bin/bash
# Bash script to install all the necessary components of the gitweb server

# CD to the source directory
source_dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

# Remove any entries in known hosts for local host - useful for testing
ssh-keygen -f ~/.ssh/known_hosts -R localhost &> /dev/null

# Remove other keys from the keys directory
rm -f ./keys/*

# Ensure we can run sudo without entering the root password
sudo echo " -- Installing <GitWeb> Container -- "

echo "Installing necessary packages . . ."
echo "  . . . docker"
sudo apt-get install docker -y > /dev/null
echo "  . . . openssh-server"
sudo apt-get install openssh-server -y > /dev/null
echo "done!"

echo "Checking for required files . . . "
if [ ! -d base_repo ];
then
	echo "ERROR - FATAL - Base gitweb repo source directory base_repo does not exist"
	echo "Pull from main project to resolve"
	exit
elif [ ! -d keys  ];
then
	echo "  . . . creating keys directory"
	mkdir keys
elif [ ! -d gitweb.git ];
then
	echo "  . . . creating base repo from source directory"
	cd base_repo
	git init > /dev/null
	git add . > /dev/null
	git commit -m "initial commit" > /dev/null
	cd ..
	git clone base_repo gitweb.git &> /dev/null
	cd base_repo
	rm -rf .git
	cd ..
elif [ ! -f Dockerfile ];
then
	echo "ERROR - FATAL - Dockerfile is missing"
	echo "Pull from main project to resolve"
	exit
elif [ ! -f startup.sh ];
then
	echo "ERROR - FATAL - image startup script missing"
	echo "Pull from  main project to resolve"
	exit
else
	echo "  . . . all present!"
fi
echo "done!"

echo "Copying SSH keys to enable access to the container . . ."
for pub in $(ls ~/.ssh/*.pub);
do
	cp $pub ./keys
	echo "  . . . "$pub
done
echo "done!"

echo "Creating and backgrounding container . . . "
if [ $(docker image list | grep gitweb | wc -l) -ne 0 ];
then
	echo "  . . . cleaning old images"
	docker container stop gitweb > /dev/null
	docker system prune -a -f > /dev/null
fi
echo "  . . . building image"
docker build . -t gitweb > /dev/null
echo "  . . . starting the container"
docker run --name gitweb -p 22:2222 -p 443:4443 -v $source_dir/keys:/gitweb/keys gitweb > /dev/null &
sleep 1
rm -rf gitweb.git
echo "done!"

echo " All set! "
echo "To close the container, enter \`docker container stop gitweb\`"
echo "To restart the container, enter \`docker run gitweb\` after closing it"
echo "To rebuild the container, rerun this script"
echo "To remove previous versions, enter \`docker system prune -a\`"
