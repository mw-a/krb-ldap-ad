#!/bin/bash

if [ `hostname -s` = 'lx01' -o `hostname -s` = 'lx02' -o `hostname -s` = 'lx03'  ]; then
  :
else
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

apt-get -y install nfs-common autofs


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


echo "/nfshome /etc/auto.nfshome" > /etc/auto.master
echo '* -fstype=nfs,rw,async,vers=4.0,sec=krb5p lx02:/srv/home/&'  > /etc/auto.nfshome

systemctl stop autofs.service > /dev/null 2>&1
systemctl start autofs.service
