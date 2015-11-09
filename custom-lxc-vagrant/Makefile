DISTRIBUTIONS = \
	wheezy \
	jessie \
	stretch \
	sid

all:
	@echo "Usage: make <distribution>"
	@echo "Available distributions: $(DISTRIBUTIONS)"

-include config.mk

help:
	@echo "Make one box: "
	@for box in $(BOXES); do echo "  $$ make $${box}"; done
	@echo
	@echo "Make all boxes: "
	@echo "  $$ make all"

BOXES = $(patsubst %, %.box, $(DISTRIBUTIONS))
LXC_PATH := $(shell lxc-config lxc.lxcpath)

$(DISTRIBUTIONS): % : %.box

test_all = $(patsubst %, test-%, $(DISTRIBUTIONS))
test: $(test_all)
$(test_all): test-% : %.box
	./test $* $<

$(BOXES): %.box : %/rootfs.tar.gz %/metadata.json %/lxc-config
	cd $* && tar czf ../$@ $(patsubst $*/%,%,$^) || ($(RM) $@; false)

%/rootfs.tar.gz: %/rootfs
	cd $* && tar czfp rootfs.tar.gz ./rootfs --numeric-owner

%/rootfs: %/base.stamp
	cp -dR --preserve=mode,ownership $(LXC_PATH)/$*-base/rootfs $@ && \
		./vagrant-setup $@ $* || \
		($(RM) -r $@; false)

%/lxc-config.in: %/base.stamp
	cp $(LXC_PATH)/$*-base/config $@

%/lxc-config: %/lxc-config.in
	./gen-lxc-config $< $@

%/base.stamp:
	lxc-destroy -n $*-base || true
	lxc-create -n $*-base -t debian -- --main-only --release $*
	mkdir -p $*
	touch $@

%/metadata.json: metadata.json.in
	mkdir -p $*
	./metadata.json.in > $@

clean: clean-base-containers
	$(RM) $(BOXES)
	$(RM) -r $(DISTRIBUTIONS)

clean-base-containers:
	for c in $(DISTRIBUTIONS); do lxc-destroy -n $$c-base || true; rm -fr /var/cache/lxc/debian/rootfs-$$c-*/; done
