#!/bin/sh

# Add unstable repository
cat << EOS > /etc/apt/sources.list.d/unstable.list
# Debian unstable
deb http://httpredir.debian.org/debian sid main contrib 
deb-src http://httpredir.debian.org/debian sid main contrib
EOS

echo 'APT::Default-Release "buster";' > /etc/apt/apt.conf.d/99target

apt-get update

