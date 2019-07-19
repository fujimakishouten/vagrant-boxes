export VAGRANT_DEFAULT_PROVIDER = virtualbox

DISTRIBUTIONS = $(basename $(wildcard *.json))
TESTED = $(addsuffix .tested, $(DISTRIBUTIONS))
SHELL = /bin/bash # needed for |&
# exit on undefined variables, pipeline fails if one command fails
.SHELLFLAGS = -u -o pipefail -c
TEE = |& ts |& tee --append $*.log # log every command
ISO_DATE_SEMVER = $(shell date +%Y.%m.%d)
TESTING_VERSION = 10.99.1
MINOR_RELEASE = 0
CHANGELOG = "* stable point release"

all:
	@echo "Usage: make <distribution>"
	@echo "Available distributions: $(DISTRIBUTIONS)"

include ../helpers/vagrantBoxTesting.mk

.PRECIOUS: %.build %.vmdk %.box

$(DISTRIBUTIONS): % : %.box
$(TESTED): % :
test-all: $(TESTED)

# set the shared folder method to rsync for most boxes
VAGRANT_FILE = Vagrantfile.in
# contrib boxes use VirtualBox default, ie vboxfs kernel module
contrib-%.box: VAGRANT_FILE= Vagrantfile-contrib.in

%.box: %.vmdk
	scripts/import2vbox.pl --memory 512 --vcpus 2 $*.vmdk $(TEE)
	mkdir -p $*.box.in
	cp $(VAGRANT_FILE) $*.box.in/Vagrantfile
	cp $*.ovf $*.box.in/box.ovf
	cp $*.vmdk $*.box.in/
	echo '{"provider": "virtualbox"}' > $*.box.in/metadata.json
	cd $*.box.in && tar czvf ../$*.box ./metadata.json ./box.ovf ./$*.vmdk ./Vagrantfile

%.vmdk: %.build
	qemu-img convert -O vmdk $</$* $*.vmdk $(TEE)

%.build:
	packer build $*.json |& ts |& tee $*.log # create a new log file

# test initialization / login / network
%.tested: %.box
	../helpers/vagrant-test virtualbox $* $< $(TEE)
	touch $@ $(TEE)

$(VAGRANT_DEFAULT_PROVIDER)-%.SHA256SUM: %.tested
	sha256sum $*.box > $@
	tr '\n' ' ' < $@ | sponge $@
	$(eval RELEASE != $(CURDIR)/../helpers/get_numeric_version.pl $*.vmdk)
	echo $(RELEASE).$(MINOR_RELEASE) >> $@

$(VAGRANT_DEFAULT_PROVIDER)-%.SHA256SUM.gpg: $(VAGRANT_DEFAULT_PROVIDER)-%.SHA256SUM
	gpg --batch --yes --sign $<

%.uploaded: $(VAGRANT_DEFAULT_PROVIDER)-%.SHA256SUM.gpg
	# extract debian version from inside the disk image
	$(eval RELEASE != $(CURDIR)/../helpers/get_numeric_version.pl $*.vmdk)
	../helpers/vagrant-cloud.pl \
		--box $*.box \
		--provider $(VAGRANT_DEFAULT_PROVIDER) \
		--version $(RELEASE).$(MINOR_RELEASE) \
		--changelog "$(CHANGELOG)" \
		--release
	touch $@

virtualbox-bullseye.SHA256SUM: buster.tested
	sha256sum bullseye.box > $@
	tr '\n' ' ' < $@ | sponge $@
	echo $(TESTING_VERSION) >> $@

virtualbox-contrib-bullseye.SHA256SUM: contrib-buster.tested
	sha256sum contrib-bullseye.box > $@
	tr '\n' ' ' < $@ | sponge $@
	echo $(TESTING_VERSION) >> $@

# we don't to use a debian version for unreleased images, hence a manual build number here
bullseye.uploaded: $(VAGRANT_DEFAULT_PROVIDER)-buster.SHA256SUM.gpg
	../helpers/vagrant-cloud.pl \
		--box bullseye.box \
		--provider $(VAGRANT_DEFAULT_PROVIDER) \
		--version $(TESTING_VERSION) \
		--changelog "$(CHANGELOG)" \
		--release
	touch $@

contrib-bullseye.uploaded: $(VAGRANT_DEFAULT_PROVIDER)-contrib-buster.SHA256SUM.gpg
	../helpers/vagrant-cloud.pl \
		--box contrib-bullseye.box \
		--provider $(VAGRANT_DEFAULT_PROVIDER) \
		--version $(TESTING_VERSION) \
		--changelog "$(CHANGELOG)" \
		--release
	touch $@

.PRECIOUS: %.vmdk $(VAGRANT_DEFAULT_PROVIDER)-%.SHA256SUM $(VAGRANT_DEFAULT_PROVIDER)-%.SHA256SUM.gpg
.PHONY: clean cleanall cleanrelease %.cleantest

clean::
	-$(RM) *.build/*
	-rmdir *.build/
	-$(RM) *.box.in/*
	-rmdir *.box.in/
	-$(RM) *.vmdk
	-$(RM) *.ovf
	-$(RM) *.SHA256SUM.gpg

cleanall: clean
	$(RM) *.box *.tested *.uploaded *.released
