#!/usr/bin/env bash

rsync -avSHP --delete rsync://anorien.csc.warwick.ac.uk/CentOS/8/BaseOS/x86_64/os/ "centos8"

#rsync -avSHP --delete rsync://anorien.csc.warwick.ac.uk/CentOS/8/ "centos8"
#wget -P $repos_base_dir wget https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Official

