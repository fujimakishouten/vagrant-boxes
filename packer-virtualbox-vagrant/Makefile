OLD_STABLE_BOX = wheezy64.box
STABLE_BOX = jessie64.box

CONTRIB_STABLE_BOX = contrib-jessie64.box
TESTING_BOX = testing64.box

all: oldstable-test stable-test

$(OLD_STABLE_BOX):
	packer build wheezy64.json
$(STABLE_BOX):
	packer build jessie64.json
$(CONTRIB_STABLE_BOX):
	packer push contrib-jessie64.json
$(TESTING_BOX):
	packer build testing64.json

define functest
 @ # $< is the fist dependency of the target
 @echo functional testing for $(<) box
 @vagrant box add --name $1 $2
 @vagrant init $1
 @vagrant up
 @vagrant ssh -c "sudo apt-get --quiet --yes install linuxlogo && linuxlogo"
 @vagrant ssh -c "test -f /vagrant/Makefile && echo -e $(tput bold) syncing successfull !"
 @vagrant halt
 @vagrant destroy --force
 @vagrant box remove $1
 @rm Vagrantfile
endef

# test initialization / login / network
oldstable-test: $(OLD_STABLE_BOX)
	$(call functest, fresh-$(<), $(OLD_STABLE_BOX))
	touch $@

stable-test: $(STABLE_BOX)
	$(call functest, fresh-$(<), $(STABLE_BOX))
	touch $@

.PHONY: clean old-stablestable

oldstable-upload: oldstable-test
	../helpers/uploadBox.pl $(patsubst %.box, %, $(OLD_STABLE_BOX))

stable-upload: stable-test
	../helpers/uploadBox.pl $(patsubst %.box, %, $(STABLE_BOX))

SHA256SUMS.gpg:
	sha256sum $(OLD_STABLE_BOX) >> SHA256SUMS
	sha256sum $(STABLE_BOX) >> SHA256SUMS
	gpg --sign SHA256SUMS

release: SHA256SUMS.gpg
	scp SHA256SUMS SHA256SUMS.gpg kdev-guest@alioth.debian.org:/home/groups/cloud/htdocs/vagrantboxes/

cleanall:
	-rm oldstable-test
	-rm stable-test
	-rm $(OLD_STABLE_BOX)
	-rm $(STABLE_BOX)
