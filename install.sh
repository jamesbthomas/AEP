#!/bin/bash
# Bash script to install all the necessary components of the gitweb server

# Ensure we can run sudo without entering the root password
sudo echo " -- Installing <GitWeb> Server and Repo -- "
echo "Running the uninstall script . . ."
./uninstall.sh > /dev/null
echo "  . . . done!"
echo "Installing OpenSSH Server . . ."
sudo apt-get install openssh-server -y > /dev/null
echo "  . . . done!"

# Capture the user name of the person who ran this script and the directory
run_user=$USER
run_dir=$(pwd)

# Create a user for the server and an ssh directory for it
# gitweb default password is gitweb
echo "Creating user gitweb with default password 'empiredidnothingwrong' . . . "
sudo adduser gitweb --gecos "gitweb,none,none,none" --disabled-password > /dev/null
echo "gitweb:empiredidnothingwrong" | sudo chpasswd > /dev/null
echo -e "\tchanging default shell to git . . . "
sudo chsh gitweb -s $(which git-shell)
echo "  . . . done!"
echo gitweb | sudo -u gitweb -S mkdir /home/gitweb/.ssh
sudo -u gitweb chmod 700 /home/gitweb/.ssh
sudo -u gitweb touch /home/gitweb/.ssh/authorized_keys
sudo -u gitweb chmod 600 /home/gitweb/.ssh/authorized_keys

# Add the SSH keys of the user who ran this script to the authorized_keys file
for pub in $(ls /home/$run_user/.ssh/*.pub)
do
	echo $(cat $pub) | sudo -u gitweb tee -a /home/gitweb/.ssh/authorized_keys > /dev/null
done

# Create the remote repository
echo "Creating gitweb repo in /srv/git/gitweb.git . . . "
sudo mkdir /srv/git
sudo mkdir /srv/git/gitweb.git
cd /srv/git/gitweb.git
sudo chown --recursive gitweb /srv/git/gitweb.git
echo -e "\tdirectories made . . . "
sudo -u gitweb git init --bare > /dev/null
echo "  . . . repo created!"

# Put a readme into the repo that has instructions for how to use gitweb
echo "Creating initial readme and testing functionality. . . "
cd $run_dir
mkdir ./test_dir
cd ./test_dir
git init > /dev/null
echo "# GitWeb Script Execution Server" > README.md
echo "The GitWeb server takes input scripts using standard git processes, executes them, and services the results in a webpage on port 443." >> README.md
echo "## Usage" >> README.md
echo "In order to have the server execute your scripts, you need to write your script, push it to the server, and open a webpage to wherever the GitWeb server is hosted on port 443." >> README.md
echo "A sample workflow to cat /etc/passwd is included below: " >> README.md
echo "\`\`\`" >> README.md
echo "echo \"cat /etc/passwd\" > script.sh" >> README.md
echo "git add script.sh" >> README.md
echo "git commit -m <commit message>" >> README.md
echo "git push" >> README.md
echo "wget <server>:443" >> README.md
echo "\`\`\`" >> README.md
echo "The file wget returns will contain the results of the script." >> README.md
echo "## Note" >> README.md
echo "Be sure to issue a \`git pull\` before creating your script to avoid conflicts on the server side." >> README.md
cat README.md > ../gitweb_readme.md

echo -e "\tTesting server functionality . . . "
git add .
git commit -m "initial commit" > /dev/null
echo "gitweb\n" | ssh -o StrictHostKeyChecking=no gitweb@127.0.0.1 &> /dev/null
git remote add origin gitweb@127.0.0.1:/srv/git/gitweb.git/ &> /dev/null
git push --set-upstream origin master &> /dev/null
cd ..
rm -rf ./test_dir
git clone gitweb@127.0.0.1:/srv/git/gitweb.git &>/dev/null
if [ $(diff gitweb/README.md gitweb_readme.md | wc -l) -ne 0 ]
then
	echo "ERROR - repo README does not match"
else
	echo "  . . . Success!"
fi

# Clean up
echo "Cleaning up the testing documents . . . "
#rm -f gitweb_readme.md
rm -rf gitweb
ssh-keygen -R 127.0.0.1 > /dev/null
rm -f /home/$run_user/.ssh/known_hosts.old
echo "Ready!"
