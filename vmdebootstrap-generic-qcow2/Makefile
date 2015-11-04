ARCH = $(shell dpkg --print-architecture)
DISTRIBUTIONS = wheezy jessie stretch sid
HTTP_PROXY_SETTING := $(shell nc -z -w 0 127.0.0.1 3142 && echo 'http_proxy=http://127.0.0.1:3142')

all:
	@echo "Usage: make <distribution>"
	@echo "Available distributions: $(DISTRIBUTIONS)"

$(DISTRIBUTIONS): % : %.qcow2.gz

.PRECIOUS: %.qcow2 %.qcow2.gz

%.gz: %
	(cat $< | gzip -) > $@ || ($(RM) $@; false)

%.qcow2: %.raw
	qemu-img convert -O qcow2 $< $@

%.raw:
	sudo \
		$(HTTP_PROXY_SETTING) \
		vmdebootstrap \
		$(VMDEBOOTSTRAP_OPTIONS) \
		--verbose \
		--size 10G \
		--distribution $* \
		--arch $(ARCH) \
		--package openssh-server \
		--package sudo \
		--serial-console \
		--hostname $* \
		--enable-dhcp \
		--log $*.log \
		--image $@ \
		|| (sudo $(RM) $@; false)
	sync
	sudo chown $(USER) $@ $*.log

clean:
	$(RM) *.raw *.qcow2 *.gz *.log
