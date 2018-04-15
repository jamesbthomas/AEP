# Container is based on the official Docker Ubuntu image
FROM alpine:3.4

# Update the image
RUN apk add --no-cache openssh git

# Setup SSH server
RUN ssh-keygen -A
RUN echo "Port 2222" >> /etc/ssh/sshd_config

# Set the working directory for the container to /gitweb
WORKDIR /gitweb/

# Copy the following files into the container
ADD startup.sh /gitweb
ADD gitweb.git /gitweb.git

# Setup source directories
RUN mkdir /gitweb/repos
RUN mkdir /gitweb/keys

# Setup gitweb user
RUN adduser -D gitweb
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
