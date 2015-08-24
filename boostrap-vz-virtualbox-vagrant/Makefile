all: oldstable stable

oldstable: /var/lib/bootstrap-vz/debian-wheezy-amd64.box
stable: /var/lib/bootstrap-vz/debian-jessie-amd64.box

/var/lib/bootstrap-vz/debian-wheezy-amd64.box: prepare_work
	LANG=C bootstrap-vz wheezy64.yml
/var/lib/bootstrap-vz/debian-jessie-amd64.box:
	LANG=C bootstrap-vz jessie64.yml

prepare_work:
	mkdir /var/lib/bootstrap-vz/

# test initialization / login / network 
stable-test: stable
	mkdir -p tests
	vagrant box add --force --name fresh_stable /var/lib/bootstrap-vz/debian-jessie-amd64.box
	vagrant init --force fresh_stable
	vagrant up
	vagrant ssh -c "sudo apt update"
	vagrant ssh -c "sudo apt --yes install screenfetch && screenfetch"
	vagrant halt

.PHONY: clean oldstable stable stable-test

clean:
	rm -r /var/lib/bootstrap-vz/*.box \
	Vagrantfile .vagrant/machines/default/virtualbox/* \
	.vagrant/
