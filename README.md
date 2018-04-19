# AEP
Thomas Technical Prompt Submission

# Instructions
To start the container that hosts the GitWeb server, run the install.sh script located in this directory. Once the container is active, you can clone the gitweb repo using "ssh gitweb@<server address>:/gitweb.git". The base repo (built from base_repo in this directory) contains a readme with instructions for using GitWeb, and a script to automate the client-side use of GitWeb, and a script that runs at start time and can be used to test your connection to the GitWeb server. This script gets deleted as soon as the server is ready so it will never appear on the client side, but navigating to https://<server address>/ls.html will return the contents of the server's repo at start timee, including the readme and gitweb.sh script, and confirming that the client has access to the GitWeb server.

## Install.sh
This script will check that all of the files the container requires are present in the current directory. If they are not present, it will rebuild the ones it couldn't find. It will also install any necessary packages, build the docker image, and start the container.

## Dockerfile
This file contains the specifications for the Docker container, including the parent image, and a set of instructions to run before the container boots. These instructions install necessary packages, create a number of directories for GitWeb to use, setup the SSH server, and copy the base repo and startup script to the container. It also creates and sets up the user account for the GitWeb server and specifies which ports on the local machine to make available to the container.

## Startup.sh
This script maintains the GitWeb server from inside the container by ensuring authorized keys are put in the correct location, starting the SSH daemon, creating and starting the SSL server, and executing script files from the git repo and furnishing the results through the SSL server on port 443.

## keys/
This directory gets mapped to a directory inside the container and is used to add SSH keys to the list of keys authorized to connect to the gitweb user.

## Notes
### Security Issues
The GitWeb server does no security checking. If given more time and had I not been restricted to only scripts, I would have preferred to implement some form of command checking on the scripts that come in such that any script that references certain directories or attempts to make use of certain networking functions would not be run.
While containerizing the server does provide some of these protections by only exposing two ports and almost immediately binding them to specific services, it would be trivial to completely subvert the server and either destroy the container or deny its services to other users.
### Design Issues
The GitWeb server can quickly run out of space as it currently has no mechanism for cleaning up script outputs. It manages to avoid putting them into the repo, but I haven't been able to get gitweb.sh to clear the html files that git server creates.
