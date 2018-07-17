#!/bin/bash

set -e

echo "installing virtualbox guest additions"

VBOXVER=5.2.10-dfsg-6~bpo9+1
td=$(mktemp -d)
cd $td
apt-get --yes install linux-headers-amd64
wget http://ftp.debian.org/debian/pool/contrib/v/virtualbox/virtualbox-guest-dkms_${VBOXVER}_all.deb
wget http://ftp.debian.org/debian/pool/contrib/v/virtualbox/virtualbox-guest-utils_${VBOXVER}_amd64.deb
dpkg -i *deb || true
apt-get --yes -f --no-install-recommends install

apt-get --yes remove --auto-remove linux-headers*-amd64
apt-get --yes autoremove
apt-get --yes clean
cd /
rm -rf $td
