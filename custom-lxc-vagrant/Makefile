-include config.mk

RELEASES = \
	stretch \
	jessie \
	wheezy

help:
	@echo "Make one box: "
	@for box in $(BOXES); do echo "  $$ make $${box}"; done
	@echo
	@echo "Make all boxes: "
	@echo "  $$ make all"

BOXES = $(patsubst %, %.box, $(RELEASES))
LXC_PATH := $(shell sudo lxc-config lxc.lxcpath)

all: $(BOXES)

test_all = $(patsubst %, test-%, $(RELEASES))
test: $(test_all)
$(test_all): test-% : %.box
	./test $* $<

$(BOXES): %.box : %/rootfs.tar.gz %/metadata.json %/lxc-config
	cd $* && sudo tar czf ../$@ $(patsubst $*/%,%,$^) || ($(RM) $@; false)

%/rootfs.tar.gz: %/rootfs
	cd $* && sudo tar czfp rootfs.tar.gz ./rootfs --numeric-owner

%/rootfs: %/base.stamp
	sudo cp -dR --preserve=mode,ownership $(LXC_PATH)/$*-base/rootfs $@ && \
		sudo ./vagrant-setup $@ $* || \
		(sudo $(RM) -r $@; false)

%/lxc-config.in: %/base.stamp
	sudo cp $(LXC_PATH)/$*-base/config $@

%/lxc-config: %/lxc-config.in
	./gen-lxc-config $< $@

%/base.stamp:
	sudo lxc-destroy -n $*-base || true
	sudo -E lxc-create -n $*-base -t debian -- --main-only --release $*
	mkdir -p $*
	touch $@

%/metadata.json: metadata.json.in
	mkdir -p $*
	./metadata.json.in > $@

clean: clean-base-containers
	$(RM) $(BOXES)
	sudo $(RM) -r $(RELEASES)

clean-base-containers:
	for c in $(RELEASES); do sudo lxc-destroy -n $$c-base || true; sudo rm -fr /var/cache/lxc/debian/rootfs-$$c-*/; done
