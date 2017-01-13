DISTRIBUTIONS = jessie stretch sid
VMDEBOOTSTRAP_OPTIONS = --customize=$(CURDIR)/../helpers/vagrant-setup --package=rsync
VAGRANT_DEFAULT_PROVIDER = libvirt

all:
	@echo "Usage: make <distribution>"
	@echo "Available distributions: wheezy $(DISTRIBUTIONS)"

$(DISTRIBUTIONS): % : %.box

wheezy:
	$(MAKE) wheezy.box EXTRA_VMDEBOOTSTRAP_OPTIONS='--roottype ext3'


%.box: %/box.img
	cp Vagrantfile.in $*/Vagrantfile
	cp metadata.json.in $*/metadata.json
	cd $* && tar cvfz ../$@ ./box.img ./Vagrantfile ./metadata.json

%/box.img: %.qcow2
	mkdir $*
	ln $< $@

clean::
	rm -rf $(DISTRIBUTIONS) *.box *.tested


# multiple calls might need a restart of libvirtd.service
# see https://bugzilla.redhat.com/show_bug.cgi?id=1221304
%.tested: %.box
	$(call functest, fresh-$(*), $(<), $(VAGRANT_DEFAULT_PROVIDER))
	touch $@

%.cleantest:
	$(call forcecleantest, fresh-$(*), $(VAGRANT_DEFAULT_PROVIDER))

include ../vmdebootstrap-generic-qcow2/common.mk
include ../helpers/vagrantBoxTesting.mk


