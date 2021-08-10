#!/usr/bin/env bash

set -euo pipefail

ANSIBLE_VAULT_PASS=`cat vpass`

sed "s/ANSIBLE_VAULT_PASS/$ANSIBLE_VAULT_PASS/g" fx-centos8.ks > ks.cfg

virt-install \
    --name fxdev00 \
    --memory 8192 \
    --vcpus 2 \
    --disk size=40 \
    --location /home/joao/src/boot/CentOS-8.4.2105-x86_64-dvd1.iso \
    --os-variant centos8 \
    --graphics none \
    --initrd-inject /home/joao/src/boot/ks.cfg \
    --console pty,target_type=serial \
    --extra-args 'console=ttyS0,115200n8 serial' \
    --extra-args 'inst.ks=file:/ks.cfg console=tty0 console=ttyS0,115200n8'

rm ks.cfg
