#!/bin/bash

set -e

echo "installing virtualbox guest additions"

VBOXVER=5.1.26-dfsg-2
td=$(mktemp -d)
cd $td
apt-get --yes install linux-headers-amd64
wget http://ftp.debian.org/debian/pool/contrib/v/virtualbox/virtualbox-guest-dkms_${VBOXVER}_all.deb
wget http://ftp.debian.org/debian/pool/contrib/v/virtualbox/virtualbox-guest-utils_${VBOXVER}_amd64.deb
dpkg -i *deb || true
apt-get --yes -f --no-install-recommends install

apt-get --yes remove linux-headers-amd64
# FIXME cleanup doesnt really work as expected
apt-get --yes autoremove
apt-get --yes clean
cd /
rm -rf $td
