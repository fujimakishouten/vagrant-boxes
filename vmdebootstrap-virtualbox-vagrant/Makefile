DISTRIBUTIONS = wheezy jessie stretch sid
VMDEBOOTSTRAP_OPTIONS = --customize=$(CURDIR)/../helpers/vagrant-setup --package=rsync

all:
	@echo "Usage: make <distribution>"
	@echo "Available distributions: $(DISTRIBUTIONS)"

$(DISTRIBUTIONS): %: %.vmdk
	VBoxManage createvm --name $@ --ostype "Debian_64" --register
	VBoxManage modifyvm $@ --memory 512
	VBoxManage storagectl $@ --name "SATA Controller" --add sata  --controller IntelAHCI --portcount 1
	# kernel waits up to three seconds for a floppy controller, so better add one for faster bootup
	VBoxManage storagectl $@ --name "Floppy Controller Controller" --add floppy
	VBoxManage storageattach $@ --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $@.vmdk
	vagrant package --base $@ --vagrantfile Vagrantfile.in --output $@.box
	VBoxManage unregistervm $@ --delete
	touch jessie

%.vmdk: %.raw
	qemu-img convert -f raw -O vmdk $< $@

jessie-test:
	$(call functest, fresh-$@, jessie.box)

cleanboxes:
	$(RM) *.box

include ../vmdebootstrap-generic-qcow2/common.mk
include ../helpers/vagrantBoxTesting.mk
