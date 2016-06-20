export VAGRANT_DEFAULT_PROVIDER = virtualbox

DISTRIBUTIONS = wheezy jessie stretch sid contrib-jessie
SHELL = /bin/bash # needed for |&

include ../helpers/vagrantBoxTesting.mk

.PRECIOUS: %.build %.vmdk %.box

all:
	@echo "Usage: make <distribution>"
	@echo "Available distributions: $(DISTRIBUTIONS)"

$(DISTRIBUTIONS): % : %.box

# set the shared floder method to rsync for most boxes
PACKAGE_FLAGS = --vagrantfile Vagrantfile.in
# contrib boxes use VirtualBox default, ie vboxfs kernel module
contrib-%.box: PACKAGE_FLAGS =

%.box: %.vmdk
	VBoxManage createvm --name $* --ostype "Debian_64" --register --basefolder $(CURDIR)/vbox/
	VBoxManage modifyvm $* --memory 512
	VBoxManage storagectl $* --name "SATA Controller" --add sata  --controller IntelAHCI --portcount 1
	# kernel waits up to three seconds for a floppy controller, so better add one for faster bootup
	VBoxManage storagectl $* --name "Floppy Controller Controller" --add floppy
	VBoxManage storageattach $* --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $*.vmdk
	vagrant package --base $* --output $*.box $(PACKAGE_FLAGS)
	VBoxManage unregistervm $*
	$(RM) vbox/$*/$*.vbox vbox/$*/$*.vbox-prev
	rmdir vbox/$*

%.vmdk: %.build
	qemu-img convert -O vmdk $</$*.raw $*.vmdk

%.build:
	packer build $*.json |& tee $*.log

clean:
	-$(RM) *.log
	-$(RM) *.build/*
	-rmdir *.build

# test initialization / login / network
%.tested: %.box clean
	$(call functest, fresh-$(*), $(<))
	touch $@

%.uploaded: $*.test
	../helpers/atlas-cli.pl $*.box

SHA256SUMS.gpg:
	sha256sum $(OLD_STABLE_BOX) >> SHA256SUMS
	sha256sum $(STABLE_BOX) >> SHA256SUMS
	gpg --sign SHA256SUMS

release: cleanrelease SHA256SUMS.gpg
	scp SHA256SUMS SHA256SUMS.gpg kdev-guest@alioth.debian.org:/home/groups/cloud/htdocs/vagrantboxes/

.PHONY: cleanall cleanrelease %.cleantest
cleanall: clean
	$(RM) *.vmdk *.box *.uploaded *.tested

%.cleantest:
	$(call forcecleantest, fresh-$(*))

cleanrelease:
	-rm SHA256SUMS.gpg
	-rm SHA256SUMS
