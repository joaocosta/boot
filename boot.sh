#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

ANSIBLE_VAULT_PASS=`cat $SCRIPT_DIR/vpass`

sed "s/ANSIBLE_VAULT_PASS/$ANSIBLE_VAULT_PASS/g" $SCRIPT_DIR/fx.ks > $SCRIPT_DIR/ks.cfg

virt-install \
    --name fxdev00 \
    --memory 2048 \
    --vcpus 2 \
    --disk size=20 \
    --location $SCRIPT_DIR/Rocky-8.5-x86_64-dvd1.iso \
    --os-variant centos8 \
    --graphics none \
    --initrd-inject $SCRIPT_DIR/ks.cfg \
    --console pty,target_type=serial \
    --extra-args 'console=ttyS0,115200n8 serial' \
    --extra-args 'inst.ks=file:/ks.cfg console=tty0 console=ttyS0,115200n8'

rm $SCRIPT_DIR/ks.cfg
