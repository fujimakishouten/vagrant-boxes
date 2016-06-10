ARCH = $(shell dpkg --print-architecture)
DISTRIBUTIONS = wheezy jessie stretch sid
HTTP_PROXY_SETTING := $(shell nc -z -w 0 127.0.0.1 3142 && echo 'http_proxy=http://127.0.0.1:3142')

all:
	@echo "Usage: make <distribution>"
	@echo "Available distributions: $(DISTRIBUTIONS)"

$(DISTRIBUTIONS): % : %.vmdk
	VBoxManage createvm --name $@ --ostype "Debian_64" --register
	VBoxManage modifyvm $@ --memory 512
	VBoxManage storagectl $@ --name "SATA Controller" --add sata  --controller IntelAHCI --portcount 1
	# kernel waits up to three seconds for a floppy controller, so better add one for faster bootup
	VBoxManage storagectl $@ --name "Floppy Controller Controller" --add floppy
	VBoxManage storageattach $@ --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $@.vmdk

%.vmdk: %.raw
	qemu-img convert -f raw -O vmdk $< $@

delete:
	VBoxManage unregistervm $(VM) --delete

include ../vmdebootstrap-generic-qcow2/common.mk
