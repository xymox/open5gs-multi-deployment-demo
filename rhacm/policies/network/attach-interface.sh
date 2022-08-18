#!/bin/sh

VM=$1

if [ "$VM" = "" ];
then
  echo "usage: `basename $0` <vm-name>"
  exit 1
fi

virsh attach-interface --domain ${VM} --type bridge \
  --source 5gcore-net --model virtio --config --persistent
