all: oldstable stable

oldstable: debian-wheezy.box
stable: debian-jessie.box
testing: debian-testing.box

debian-wheezy.box:
	packer build debian-7-wheezy-virtualbox.json
debian-jessie.box:
	packer build debian-8-jessie-virtualbox.json
debian-testing.box:
	packer build debian-9-testing-virtualbox.json

define functest
 @echo functional testing for $< box
 vagrant box add --force --name $1 $2
 vagrant init --force $1
 vagrant up
 vagrant ssh -c "sudo apt-get -y install screenfetch && screenfetch"
 vagrant halt
 vagrant destroy --force
 vagrant box remove $1
 rm Vagrantfile
endef

# test initialization / login / network 
stable-test: stable
	$(call functest, fresh_stable, debian-jessie.box)

.PHONY: clean oldstable stable stable-test

SHA256SUMS.gpg:
	sha256sum debian-jessie.box >> SHA256SUMS
	sha256sum debian-wheezy.box >> SHA256SUMS
	gpg --sign SHA256SUMS
