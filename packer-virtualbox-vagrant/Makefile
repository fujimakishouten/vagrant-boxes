export VAGRANT_DEFAULT_PROVIDER = virtualbox

DISTRIBUTIONS = wheezy jessie stretch sid contrib-jessie
TESTED = wheezy.tested jessie.tested contrib-jessie.tested
SHELL = /bin/bash # needed for |&
# exit on undefined variables, pipeline fails if one command fails
.SHELLFLAGS = -u -o pipefail -c
TEE = |& tee --append $*.log # log every command

include ../helpers/vagrantBoxTesting.mk

.PRECIOUS: %.build %.vmdk %.box

all:
	@echo "Usage: make <distribution>"
	@echo "Available distributions: $(DISTRIBUTIONS)"

$(DISTRIBUTIONS): % : %.box
$(TESTED): % :

# set the shared floder method to rsync for most boxes
PACKAGE_FLAGS = --vagrantfile Vagrantfile.in
# contrib boxes use VirtualBox default, ie vboxfs kernel module
contrib-%.box: PACKAGE_FLAGS =

%.box: %.vmdk
	VBoxManage createvm --name $* --ostype "Debian_64" --register --basefolder $(CURDIR)/vbox/ $(TEE)
	VBoxManage modifyvm $* --memory 512 $(TEE)
	VBoxManage storagectl $* --name "SATA Controller" --add sata  --controller IntelAHCI --portcount 1 $(TEE)
	# kernel waits up to three seconds for a floppy controller, so better add one for faster bootup
	VBoxManage storagectl $* --name "Floppy Controller Controller" --add floppy $(TEE)
	VBoxManage storageattach $* --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $*.vmdk $(TEE)
	vagrant package --base $* --output $*.box $(PACKAGE_FLAGS) $(TEE)
	VBoxManage unregistervm $* $(TEE)
	$(RM) vbox/$*/$*.vbox vbox/$*/$*.vbox-prev $(TEE)
	rmdir vbox/$* $(TEE)

%.vmdk: %.build
	qemu-img convert -O vmdk $</$*.raw $*.vmdk $(TEE)

%.build:
	packer build $*.json $(TEE)

# test initialization / login / network
%.tested: %.box
	make clean $(TEE) # don't try to rsync gigabytes of data to the vm
	$(call functest, fresh-$(*), $(<), $(VAGRANT_DEFAULT_PROVIDER)) $(TEE)
	touch $@ $(TEE)

%.uploaded: %.tested
	../helpers/atlas-cli.pl --box $*.box
	touch $@

%.SHA256SUM.gpg: %.uploaded
	make $*.cleansign
	sha256sum $*.box > $(VAGRANT_DEFAULT_PROVIDER)-$*64.SHA256SUM
	gpg --sign $(VAGRANT_DEFAULT_PROVIDER)-$*64.SHA256SUM

%.released: %.SHA256SUM.gpg
	scp $(VAGRANT_DEFAULT_PROVIDER)-$*64.SHA256SUM \
	    $(VAGRANT_DEFAULT_PROVIDER)-$*64.SHA256SUM.gpg \
	    kdev-guest@alioth.debian.org:/home/groups/cloud/htdocs/vagrantboxes/
	@echo "everything done, please release the box $*64 on atlas.com"
	touch $@

.PHONY: clean cleanall cleanrelease %.cleantest

clean:
	-$(RM) *.build/*
	-$(RM) *.vmdk
	-rmdir *.build

cleanall: clean
	$(RM) *.box *.uploaded *.tested *.log

%.cleantest:
	$(call forcecleantest, fresh-$(*), $(VAGRANT_DEFAULT_PROVIDER))

%.cleansign:
	-rm $(VAGRANT_DEFAULT_PROVIDER)-$*64.SHA256SUM.gpg
	-rm $(VAGRANT_DEFAULT_PROVIDER)-$*64.SHA256SUM
