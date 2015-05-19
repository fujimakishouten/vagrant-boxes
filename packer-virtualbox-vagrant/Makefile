all: oldstable stable

oldstable: debian-780-wheezy.box
stable: debian-800-jessie.box
testing: debian-testing-stretch.box

debian-780-wheezy.box:
	packer build debian-7-wheezy-virtualbox.json
debian-800-jessie.box:
	packer build debian-8-jessie-virtualbox.json
debian-testing-stretch.box:
	packer build debian-9-stretch-virtualbox.json

# test initialization / login / network 
stable-test: stable
	mkdir -p tests
	vagrant init --force stable debian-800-jessie.box
	vagrant up
	vagrant ssh -c "sudo apt-get -y install screenfetch && screenfetch"

.PHONY: clean oldstable stable testing stable-test

clean:
	rm *.box
