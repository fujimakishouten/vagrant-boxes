all: oldstable stable

oldstable: debian-wheezy.box
stable: debian-jessie.box
testing: debian-testing-stretch.box

debian-wheezy.box:
	packer build debian-7-wheezy-virtualbox.json
debian-jessie.box:
	packer build debian-8-jessie-virtualbox.json
debian-testing-stretch.box:
	packer build debian-9-stretch-virtualbox.json

# test initialization / login / network 
stable-test: stable
	vagrant box add --force --name fresh_stable debian-jessie.box
	vagrant init --force fresh_stable
	vagrant up
	vagrant ssh -c "sudo apt-get -y install screenfetch && screenfetch"
	vagrant halt

.PHONY: clean oldstable stable testing stable-test release

clean:
	rm -r *.box Vagrantfile .vagrant/machines/default/virtualbox/* .vagrant/

SHA256SUMS.gpg:
	sha256sum debian-jessie.box >> SHA256SUMS
	sha256sum debian-wheezy.box >> SHA256SUMS
	gpg --sign SHA256SUMS
