#!/bin/bash
# NB: trap signal has bash semantics

export OS=Debian8

python -m SimpleHTTPServer & 2> /dev/null
child_pid=$!

virt-install \
--connect qemu:///session \
--name ${OS} \
--ram 512 \
--vcpus 1 \
--file ${OS}.qcow2 \
--file-size=4 \
--location http://httpredir.debian.org/debian/dists/stable/main/installer-amd64/ \
--virt-type kvm \
--os-variant Debian8 \
--network=user \
--noreboot \
--graphics none \
--console pty,target_type=serial \
--extra-args "auto=true hostname=${OS} domain= url=http://10.0.2.2:8000/vanilla-debian-8-jessie-preseed.cfg console=ttyS0,115200n8 DEBIAN_FRONTEND=text"

kill $child_pid
virsh undefine $OS

trap "kill $child_pid; virsh undefine $OS" SIGINT SIGTERM
