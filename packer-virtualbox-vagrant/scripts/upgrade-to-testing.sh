#!/bin/bash

set -e
cat > /etc/apt/sources.list <<-EOF
deb http://deb.debian.org/debian testing main
deb-src http://deb.debian.org/debian testing main

deb http://deb.debian.org/debian sid main
deb-src http://deb.debian.org/debian sid main
EOF

cat > /etc/apt/preferences <<-EOF
Package: *
Pin: release a=testing
Pin-Priority: 900

Package: *
Pin: release a=unstable
Pin-Priority: 800
EOF

apt-get update
apt-get --yes upgrade
apt-get --yes dist-upgrade
apt-get --yes autoremove
apt-get --yes clean
reboot
