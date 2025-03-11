#!/bin/bash

[ `hostname -s` != 'lx02' ] && exit 1

export DEBIAN_FRONTEND=noninteractive

apt-get -y install nfs-common nfs-kernel-server msktutil

# gssproxy disables rpc-svcgssd and requires configuration
apt-get -y remove gssproxy

for i in {10..99} ; do
    mkdir -p /srv/home/user$i /srv/home/adsuser$i /srv/home/subuser$i
    chown user$i:group$i /srv/home/user$i
    chown adsuser$i:adsgroup$i /srv/home/adsuser$i
    chown subuser$i:subgroup$i /srv/home/subuser$i
done
chmod 0700 /srv/home/*user*

echo P@ssw0rd | kinit Administrator || exit 1
msktutil --update --enctypes 0x10 --set-samba-secret --service nfs
kdestroy

cat > /etc/exports <<EOF
/srv/home *(rw,subtree_check,sec=krb5)
EOF

cat > /etc/idmapd.conf <<EOF
[General]

Verbosity = 0
Pipefs-Directory = /run/rpc_pipefs
# set your own domain here, if it differs from FQDN minus hostname
Domain = example.com
Local-Realms = EXAMPLE.COM,ADS.EXAMPLE.COM,SUBDOM.ADS.EXAMPLE.COM

[Mapping]

Nobody-User = nobody
Nobody-Group = nogroup
EOF

systemctl stop nfs-server.service > /dev/null 2>&1
systemctl start nfs-server.service
