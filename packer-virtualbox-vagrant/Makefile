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

# set the shared folder method to rsync for most boxes
VAGRANT_FILE = Vagrantfile.in
# contrib boxes use VirtualBox default, ie vboxfs kernel module
contrib-%.box: VAGRANT_FILE= Vagrantfile-contrib.in

%.box: %.vmdk
	import2vbox --memory 512 --vcpus 2 $*.vmdk $(TEE)
	mkdir -p $*.box.in
	cp $(VAGRANT_FILE) $*.box.in/Vagrantfile
	cp $*.ovf $*.box.in/box.ovf
	cp $*.vmdk $*.box.in/
	echo '{"provider": "virtualbox"}' > $*.box.in/metadata.json
	cd $*.box.in && tar czvf ../$*.box ./metadata.json ./box.ovf ./$*.vmdk ./Vagrantfile

%.vmdk: %.build
	qemu-img convert -O vmdk $</$* $*.vmdk $(TEE)

%.build:
	packer build $*.json |& tee $*.log # create a new log file

# test initialization / login / network
%.tested: %.box
	make clean $(TEE) # don't try to rsync gigabytes of data to the vm
	#TODO replace with shellp helper ../helpers/vagrant-test
	$(call functest, fresh-$(*), $(<), $(VAGRANT_DEFAULT_PROVIDER)) $(TEE)
	touch $@ $(TEE)

testing.uploaded: ISO_DATE_SEMVER = --version $(shell date +%Y.%m.%d)
%.uploaded: %.tested
	../helpers/atlas-cli.pl --box $*.box $(ISO_DATE_SEMVER)
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

clean::
	-$(RM) *.build/*
	-rmdir *.build/
	-$(RM) *.box.in/*
	-rmdir *.box.in/
	-$(RM) *.vmdk
	-$(RM) *.ovf

cleanall: clean
	$(RM) *.box *.uploaded *.tested *.log

%.cleantest:
	$(call forcecleantest, fresh-$(*), $(VAGRANT_DEFAULT_PROVIDER))

%.cleansign:
	-rm $(VAGRANT_DEFAULT_PROVIDER)-$*64.SHA256SUM.gpg
	-rm $(VAGRANT_DEFAULT_PROVIDER)-$*64.SHA256SUM
