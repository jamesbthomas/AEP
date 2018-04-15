#!/bin/bash
# Bash script used for running scripts using the GitWeb container

git pull > /dev/null
# Install curl so we can use it to grab all of the files
sudo apt-get install curl &> /dev/null

# TODO address of the GitWeb server
addr=localhost	# Default is set to localhost
# TODO address of the GitWeb server

# Make sure we're in a git repo
git status > /dev/null
if [ $? -ne 0 ];
then
	echo "ERROR - Not a git repo"
fi

# Make sure we're in a gitweb repo
if [ $(git remote -v | grep gitweb | wc -l) -ne 2 ];
then
	echo "ERROR - Not a GitWeb repo"
fi

# Commit and push
echo "Pushing scripts..."
scripts=$(ls ./*.sh | grep -v gitweb.sh)
for file in $scripts;
do
	echo $file pushed
	git add $file
done
git commit -m "scripts" > /dev/null
git push &> /dev/null

# Connect to the server and pull the results
git pull > /dev/null

echo "Getting results..."
touch clear.sh
for file in $scripts;
do
	cp $file $file.old
	htmlname=$(echo $file | awk -F"." '{print $2}' | awk -F"/" '{print $2}').html
	# build the script to clear my results
	echo "rm -f ../"$htmlname | tee clear.sh
	curl https://$addr/$htmlname -k > $htmlname 2> /dev/null
done

cat clear.sh

echo "Clearing..."
# push a script to delete the html file
git add clear.sh > /dev/null
git commit -m "clearing" > /dev/null
git push &> /dev/null

# close out and make sure the repo is up to date
sleep 1
git pull &> /dev/null
rm -f clear.sh
