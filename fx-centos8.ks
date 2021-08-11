#version=RHEL8
# Use text install
text
skipx

repo --name="AppStream" --baseurl=file:///run/install/sources/mount-0000-cdrom/AppStream

%packages
@^minimal-environment

%end

# Keyboard layouts
keyboard --xlayouts='gb'
# System language
lang en_GB.UTF-8

# Network information
network --bootproto=static --ip=192.168.122.100 --gateway=192.168.122.1 --netmask=255.255.255.0 --noipv6 --device=enp1s0 --nameserver=192.168.122.1,8.8.8.8 --activate
#network  --bootproto=dhcp --device=enp1s0 --noipv6 --activate
network  --hostname=node-00.fxdev00

# Use CDROM installation media
cdrom

firstboot --disable

eula --agreed

selinux --disabled

ignoredisk --only-use=vda
autopart
# Partition clearing information
clearpart --none --initlabel

# System timezone
timezone Etc/GMT --isUtc

# Root password
rootpw --iscrypted $6$R2q2d7dj8tlY3GaS$yAjFqE2X7NU.NalE6a.oRpQDzXdjYXkfy5ddQjRkukI8/m8fqSEPTz7PR2hUmQUfi3N3JWhsiZSPKekbHMJLH/

poweroff

%addon com_redhat_kdump --disable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end

%post --log=/root/postinstall.log

yum -y install epel-release
yum -y update
yum -y install augeas git ansible python3-docker
yum -y module reset nginx
yum -y module enable nginx:1.20

augtool -s <<EOF
set /files/etc/grub.conf/timeout 0
EOF

ssh-keyscan github.com >> /etc/ssh/ssh_known_hosts

# Clone the https url so that an ssh key is not needed
git clone https://github.com/fx-trader/fx-ansible.git /root/fx-ansible

# Change the protocol back to ssh so that when i start working with the machine later I can use an ssh key to authenticate git push
sed -i 's|https://github.com/|git@github.com:|' /root/fx-ansible/.git/config
/root/fx-ansible/extensions/setup/role_update.sh
ansible-galaxy collection install -p /root/.ansible/collections ansible.posix

echo ANSIBLE_VAULT_PASS > /root/fx-ansible/.vpass


cat << EOF > /etc/systemd/system/ansible-config-me.service
[Unit]
Description=Run ansible-playbook at first boot to apply environment configuration
After=network.target

[Service]
ExecStart=/root/ansible-config-me.sh
Type=oneshot

[Install]
WantedBy=multi-user.target
EOF
chmod 0644 /etc/systemd/system/ansible-config-me.service


cat << EOF > /root/ansible-config-me.sh
#!/bin/bash

set -euo pipefail

cd ~/fx-ansible/plays
ansible-playbook -i ../environments/development fx.yml >> /root/ansible-run-fx.yml.log

docker run --rm -v /root/fx/cfg:/etc/fxtrader --link fxdatafeed:fxdatafeed fxtrader/finance-hostedtrader bash -c "fx-create-db-schema.pl | fx-db-client.pl" >> /root/ansible-run-fx.yml.log
docker run --rm --link snipers-db:snipers-db fxtrader/snipers-api ruby /webapp/db/schema.rb >> /root/ansible-run-fx.yml.log

systemctl disable ansible-config-me.service
EOF
chmod 0755 /root/ansible-config-me.sh

systemctl daemon-reload
systemctl enable ansible-config-me.service

#cd /root/fx-ansible/plays
#ansible-playbook -i ../environments/development fx.yml
#ansible-playbook dev.yml
%end
