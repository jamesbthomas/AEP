# Container is based on the official Docker Ubuntu image
FROM alpine:3.4

# Update the image
RUN apk add --no-cache openssh git openssl

# Setup SSH Daemon
RUN ssh-keygen -A
RUN echo "Port 2222" >> /etc/ssh/sshd_config

# Set the working directory for the container to /gitweb
WORKDIR /gitweb/

# Copy the following files into the container
## startup script that maintains the container
ADD startup.sh /gitweb
## repo so we don't have to worry about creating it in the script
ADD gitweb.git /gitweb.git

# Setup source directories
RUN mkdir /gitweb/keys #mapped to project_root/keys used for adding to the git server's list of authorized keys

# Setup gitweb user
RUN adduser -D gitweb
# -s /usr/bin/git-shell
RUN echo "gitweb:empiredidnothingwrong" | chpasswd
RUN mkdir /home/gitweb/.ssh
RUN git config --global user.email "gitweb@gitweb.com"
RUN git config --global user.name "gitweb"

# Make port 22 available for git over SSH
EXPOSE 22
# Make port 443 available for the web server
EXPOSE 443

# Run setup.sh when the container launches
CMD ["/bin/sh","startup.sh"]
