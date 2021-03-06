#!/bin/bash

# Update the package index
echo "************************  apt-get update  ************************"
apt-get update

# Install util packages
echo "************************  install git  ************************"
apt-get install git socat -y

# Install Docker
echo "************************  install docker  ************************"
wget -qO- https://get.docker.com/ | sh
usermod -aG docker vagrant

# Configure the subnet heig
echo "************************  Configure the subnet heig  **************"
docker network create --driver bridge heig

# Build the haproxy image
echo "************************  build haproxy image  ************************"
cd /vagrant/ha
docker build -t softengheigvd/ha .

# Build the webapp image
echo "************************  build webapp image  ************************"
cd /vagrant/webapp
docker build -t softengheigvd/webapp .

# Run load balancer
echo "************************  run haproxy  ************************"
docker rm -f ha 2>/dev/null || true
docker run -d -p 80:80 -p 1936:1936 -p 9999:9999 --network heig --name ha softengheigvd/ha

# Run two webapps
echo "************************  run webapps  ************************"
docker rm -f s1 2>/dev/null || true
docker rm -f s2 2>/dev/null || true
docker run -d --network heig --name s1 softengheigvd/webapp
docker run -d --network heig --name s2 softengheigvd/webapp
