#!/bin/sh

python -m SimpleHTTPServer &
child_pid=$!

export OS=Debian8

virt-install \
--connect qemu:///session \
--name ${OS} \
--ram 512 \
--vcpus 1 \
--file ${OS}.img \
--file-size=4 \
--location http://http.debian.net/debian/dists/stable/main/installer-amd64/ \
--virt-type kvm \
--os-variant Debian8 \
--network=user \
--console pty,target_type=serial \
--graphics none \
--extra-args "auto=true hostname=${OS} domain= url=http://10.0.2.2:8000/vanilla-debian-8-jessie-preseed.cfg text console=ttyS0,115200n8 serial TERM=bterm"
kill $child_pid
