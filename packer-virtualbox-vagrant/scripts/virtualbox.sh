echo "installing virtualbox guest additions"

# install virtualbox additions build dependancies
apt-get --yes install linux-headers-$(uname -r) build-essential dkms


# If libdbus is not installed, virtualbox will not autostart
apt-get -y install --no-install-recommends libdbus-1-3

# deprecated: this remove virtualbox additions installed
# from the debian installer pre-wheezy release

#if test -f .vbox_version ; then
  # The netboot installs the VirtualBox support (old) so we have to remove it
#  if test -f /etc/init.d/virtualbox-ose-guest-utils ; then
#    /etc/init.d/virtualbox-ose-guest-utils stop
#  fi

#  rmmod vboxguest
#  aptitude -y purge virtualbox-ose-guest-x11 virtualbox-ose-guest-dkms virtualbox-ose-guest-utils
#fi

# Install the VirtualBox guest additions
mount -o loop VBoxGuestAdditions.iso /mnt
yes|sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm -f VBoxGuestAdditions.iso

# Start the newly build driver
service vboxadd start

# cleanup virtualbox stuff
apt-get --yes remove linux-headers-$(uname -r) build-essential dkms
