DISTRIBUTIONS = wheezy jessie stretch sid
VMDEBOOTSTRAP_OPTIONS = --customize=$(CURDIR)/../helpers/vagrant-setup --package=rsync

all:
	@echo "Usage: make <distribution>"
	@echo "Available distributions: $(DISTRIBUTIONS)"

$(DISTRIBUTIONS): % : %.box

%.box: %/box.img
	cp Vagrantfile.in $*/Vagrantfile
	cp metadata.json.in $*/metadata.json
	cd $* && tar cvfz ../$@ ./box.img ./Vagrantfile ./metadata.json

%/box.img: %.qcow2
	mkdir $*
	ln $< $@

clean::
	rm -rf $(DISTRIBUTIONS) *.box

include ../vmdebootstrap-generic-qcow2/common.mk


