ARCH = $(shell dpkg --print-architecture)
DISTRIBUTIONS = wheezy jessie stretch buster sid
HTTP_PROXY_SETTING := $(shell nc -z -w 0 127.0.0.1 3142 && echo 'http_proxy=http://127.0.0.1:3142')

all:
	@echo "Usage: make <distribution>"
	@echo "Available distributions: $(DISTRIBUTIONS)"

$(DISTRIBUTIONS): % : %.qcow2.gz

include common.mk

