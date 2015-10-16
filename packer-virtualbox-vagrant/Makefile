all: oldstable stable

OLD_STABLE_BOX = debian-wheezy.box
STABLE_BOX = debian-jessie.box
TESTING_BOX = debian-stretch.box

oldstable: $(OLD_STABLE_BOX)
stable: $(STABLE_BOX)
testing: $(TESTING_BOX)

$(OLD_STABLE_BOX):
	packer build debian-7-wheezy-virtualbox.json
$(STABLE_BOX):
	packer build debian-8-jessie-virtualbox.json
$(TESTING_BOX):
	packer build debian-9-testing-virtualbox.json

define functest
 @ # $< is the fist dependency of the target
 @echo functional testing for $(<) box
 @vagrant box add --force --name $1 $2
 @vagrant init --force $1
 @vagrant up
 @vagrant ssh -c "sudo apt-get --quiet --yes install linuxlogo && linuxlogo"
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
