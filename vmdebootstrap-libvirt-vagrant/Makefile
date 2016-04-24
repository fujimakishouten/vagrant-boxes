DISTRIBUTIONS = wheezy jessie stretch sid
VMDEBOOTSTRAP_OPTIONS = --customize=$(CURDIR)/vagrant-setup

all:
	@echo "Usage: make <distribution>"
	@echo "Available distributions: $(DISTRIBUTIONS)"

$(DISTRIBUTIONS): % : %.box

%.box: %/box.img
	cp Vagrantfile $*/
	cp metadata.json $*/
	cd $* && tar cvfz ../$@ ./box.img ./Vagrantfile ./metadata.json

%/box.img: %.qcow2
	mkdir $*
	ln $< $@

clean::
	rm -rf $(DISTRIBUTIONS) *.box

include ../vmdebootstrap-generic-qcow2/common.mk


