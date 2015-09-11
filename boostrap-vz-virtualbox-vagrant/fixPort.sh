#!/bin/bash
test -n "$1" || { echo "missing VM id" && exit 1; }

VBoxManage storagectl  $1 --controller IntelAHCI --name "SATA Controller" --portcount 1
