DISTRIBUTIONS = wheezy jessie stretch sid
VMDEBOOTSTRAP_OPTIONS = --customize=$(CURDIR)/../helpers/vagrant-setup --package=rsync
export VAGRANT_DEFAULT_PROVIDER = virtualbox
#.PRECIOUS: %.raw %.vmdk
#this makefiles abuses from automatic variables
#see https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html

all:
	@echo "Usage: make <distribution>"
	@echo "Available distributions: $(DISTRIBUTIONS)"

$(DISTRIBUTIONS): %: %.box

%.box: %.vmdk
	VBoxManage createvm --name $* --ostype "Debian_64" --register --basefolder $(CURDIR)/vbox/
	VBoxManage modifyvm $* --memory 512
	VBoxManage storagectl $* --name "SATA Controller" --add sata  --controller IntelAHCI --portcount 1
	# kernel waits up to three seconds for a floppy controller, so better add one for faster bootup
	VBoxManage storagectl $* --name "Floppy Controller Controller" --add floppy
	VBoxManage storageattach $* --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $*.vmdk
	vagrant package --base $* --vagrantfile Vagrantfile.in --output $*.box
	VBoxManage unregistervm $*
	$(RM) vbox/$*/$*.vbox vbox/$*/$*.vbox-prev
	rmdir vbox/$*

%.vmdk: %.raw
	qemu-img convert -f raw -O vmdk $< $@

%.test: %.box
	# keeping this makes the test run out of disk space in the VM
	$(RM) *.raw *.vmdk
	$(call functest, fresh-$*, $<)
	touch $@

.PHONY: forcecleantest
forcecleantest:
	$(call forcecleantest, fresh-jessie)

cleanall:
	$(RM) *.box *.test

include ../vmdebootstrap-generic-qcow2/common.mk
include ../helpers/vagrantBoxTesting.mk
