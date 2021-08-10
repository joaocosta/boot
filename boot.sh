#!/usr/bin/env bash

virt-install \
    --name fxdev00 \
    --memory 8192 \
    --vcpus 2 \
    --disk size=40 \
    --location /home/joao/src/boot/CentOS-8.4.2105-x86_64-dvd1.iso \
    --os-variant centos8 \
    --graphics none \
    --initrd-inject /home/joao/src/boot/fx-centos8.ks \
    --console pty,target_type=serial \
    --extra-args 'console=ttyS0,115200n8 serial' \
    --extra-args 'inst.ks=file:/fx-centos8.ks console=tty0 console=ttyS0,115200n8'
