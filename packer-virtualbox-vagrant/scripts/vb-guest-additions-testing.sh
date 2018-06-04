#!/bin/bash

set -e

echo "installing virtualbox guest additions"

cat > /etc/apt/sources.list.d/contrib.list <<-EOF
deb http://deb.debian.org/debian testing contrib
deb-src http://deb.debian.org/debian testing contrib

deb http://deb.debian.org/debian sid contrib
deb-src http://deb.debian.org/debian sid contrib
EOF

apt-get update
apt-get --yes install linux-headers-amd64 dpkg-dev
# FIXME we currently install virtualbox from unstable due to #897928 but we should revert
# to using testing when a fixed version will reach testing
apt-get --yes --no-install-recommends install virtualbox-guest-dkms/unstable virtualbox-guest-utils/unstable

apt-get --yes remove --auto-remove linux-headers*-amd64 dpkg-dev
apt-get --yes autoremove
apt-get --yes clean
