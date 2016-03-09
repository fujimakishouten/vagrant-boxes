DISTRIBUTION = debian
RELEASES = \
	wheezy \
	jessie \
	stretch \
	sid
LXC_CREATE_OPTIONS = --main-only

all:
	@echo "Usage: make <release>"
	@echo "Available releases: $(RELEASES)"

-include config.mk

help:
	@echo "Make one box: "
	@for box in $(BOXES); do echo "  $$ make $${box}"; done
	@echo
	@echo "Make all boxes: "
	@echo "  $$ make all"

BOXES = $(patsubst %, %.box, $(RELEASES))
LXC_PATH := $(shell lxc-config lxc.lxcpath)

$(RELEASES): % : %.box

test_all = $(patsubst %, test-%, $(RELEASES))
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
	lxc-create -n $*-base -t $(DISTRIBUTION) -- $(LXC_CREATE_OPTIONS) --release $*
	mkdir -p $*
	touch $@

%/metadata.json: metadata.json.in
	mkdir -p $*
	./metadata.json.in > $@

clean: clean-base-containers
	$(RM) $(BOXES)
	$(RM) -r $(RELEASES)

clean-base-containers:
	for c in $(RELEASES); do lxc-destroy -n $$c-base || true; rm -fr /var/cache/lxc/$(DISTRIBUTION)/rootfs-$$c-*/; done
