all: oldstable stable

oldstable: debian-wheezy.box
stable: debian-jessie.box
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
	vagrant box add --force --name fresh_stable debian-jessie.box
	vagrant init --force fresh_stable
	vagrant up
	vagrant ssh -c "sudo apt-get -y install screenfetch && screenfetch"

.PHONY: clean oldstable stable testing stable-test

clean:
	rm -r *.box Vagrantfile .vagrant/machines/default/virtualbox/* .vagrant/
