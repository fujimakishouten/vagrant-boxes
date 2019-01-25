#!/bin/bash

set -e

echo "installing virtualbox guest additions"
apt-get --yes install linux-headers-amd64 devscripts

VBOXVER=$(rmadison --suite stretch-backports virtualbox-guest-dkms \
	| awk -F'|' '{print $2}' \
	| sed s/\ //g)

td=$(mktemp -d)
cd $td
wget http://ftp.debian.org/debian/pool/contrib/v/virtualbox/virtualbox-guest-dkms_${VBOXVER}_all.deb
wget http://ftp.debian.org/debian/pool/contrib/v/virtualbox/virtualbox-guest-utils_${VBOXVER}_amd64.deb
dpkg -i *deb || true
apt-get --yes -f --no-install-recommends install

apt-get --yes remove --auto-remove linux-headers*-amd64 devscripts
apt-get --yes autoremove
apt-get --yes clean
cd /
rm -rf $td
