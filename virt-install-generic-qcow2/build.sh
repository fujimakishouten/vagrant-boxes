#!/bin/sh

export OS=$1

python -m SimpleHTTPServer & 2> /dev/null
child_pid=$!
trap "kill $child_pid ; virsh undefine $OS" INT QUIT TERM

virt-install \
--connect qemu:///session \
--name ${OS} \
--ram 512 \
--vcpus 2 \
--disk path=${OS}.qcow2,size=4,bus=scsi \
--controller type=scsi,model=virtio-scsi \
--location http://deb.debian.org/debian/dists/stable/main/installer-amd64/ \
--virt-type kvm \
--os-variant Debian9 \
--network=user \
--noreboot \
--graphics none \
--console pty,target_type=serial \
--extra-args "auto=true hostname=${OS} domain= url=http://10.0.2.2:8000/stretch-preseed.cfg DEBIAN_FRONTEND=text --- console=ttyS0,115200n8"

kill $child_pid
virsh undefine $OS
