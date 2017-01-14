DISTRIBUTIONS = jessie stretch sid
VMDEBOOTSTRAP_OPTIONS = --customize=$(CURDIR)/../helpers/vagrant-setup --package=rsync

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

test_all = test-wheezy $(patsubst %, test-%, $(DISTRIBUTIONS))
test: $(test_all)
$(test_all): test-% : %.box
	../helpers/vagrant-test libvirt $* $<


clean::
	rm -rf wheezy $(DISTRIBUTIONS) *.box *.tested

include ../vmdebootstrap-generic-qcow2/common.mk
