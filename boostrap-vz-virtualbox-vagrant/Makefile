.DEFAULT_GOAL := $(CONTRIB_STABLE_BOX)

export VAGRANT_DEFAULT_PROVIDER = virtualbox
BVZ_OUTPUT = /var/lib/bootstrap-vz

OLD_STABLE_BOX = $(BVZ_OUTPUT)/debian-wheezy-amd64.box
STABLE_BOX = $(BVZ_OUTPUT)/debian-jessie-amd64.box

CONTRIB_STABLE_BOX = $(BVZ_OUTPUT)/contrib-jessie-amd64.box

#all: oldstable-test stable-test
all: contrib-stable-test

$(OLD_STABLE_BOX):
	sudo LANG=C bootstrap-vz wheezy64.yml
$(STABLE_BOX):
	sudo LANG=C bootstrap-vz --debug jessie64.yml
$(CONTRIB_STABLE_BOX):
	sudo LANG=C bootstrap-vz --debug contrib-jessie64.yml

prepare_work:
	mkdir -p /var/lib/bootstrap-vz/

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
	$(call functest, fresh-oldstable-bvz, $(<))
	touch $@

stable-test: $(STABLE_BOX)
	$(call functest, fresh-stable-bvz, $(<))
	touch $@

contrib-stable-test: $(CONTRIB_STABLE_BOX)
	$(call functest, fresh-contrib-stable-bvz, $(<))
	touch $@

.PHONY: clean old-stablestable

bench:
	vagrant halt
	vagrant up
	vagrant ssh -c "systemd-analyze"

cleanall:
	-rm oldstable-test
	-rm stable-test
	-rm $(OLD_STABLE_BOX)
	-rm $(STABLE_BOX)
