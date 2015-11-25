all: oldstable-test stable-test

OLD_STABLE_BOX = debian-wheezy64.box
STABLE_BOX = debian-jessie64.box
TESTING_BOX = debian-testing64.box

oldstable: $(OLD_STABLE_BOX)
stable: $(STABLE_BOX)
testing: $(TESTING_BOX)

$(OLD_STABLE_BOX):
	packer build wheezy64-virtualbox.json
$(STABLE_BOX):
	packer build jessie64-virtualbox.json
$(TESTING_BOX):
	packer build testing64-virtualbox.json

define functest
 @ # $< is the fist dependency of the target
 @echo functional testing for $(<) box
 @vagrant box add --name $1 $2
 @vagrant init $1
 @vagrant up
 @vagrant ssh -c "sudo apt-get --quiet --yes install linuxlogo && linuxlogo"
 @vagrant ssh -c "test -f /vagrant/Makefile && echo -e $(tput bold) rsyncing successfull !"
 @vagrant halt
 @vagrant destroy --force
 @vagrant box remove $1
 @rm Vagrantfile
endef

# test initialization / login / network
oldstable-test: oldstable
	$(call functest, fresh-$(<), $(OLD_STABLE_BOX))

stable-test: stable
	$(call functest, fresh-$(<), $(STABLE_BOX))


.PHONY: clean oldstable stable stable-test

SHA256SUMS.gpg:
	sha256sum $(OLD_STABLE_BOX) >> SHA256SUMS
	sha256sum $(STABLE_BOX) >> SHA256SUMS
	gpg --sign SHA256SUMS

release: SHA256SUMS.gpg
	scp SHA256SUMS SHA256SUMS.gpg kdev-guest@alioth.debian.org:/home/groups/cloud/htdocs/vagrantboxes/
