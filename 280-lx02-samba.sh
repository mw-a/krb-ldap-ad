[ `hostname -s` != 'lx02' ] && exit 1

for i in `seq -w 1 99`; do
    mkdir -p /srv/home/user$i /srv/home/adsuser$i /srv/home/subuser$i
    chown user$i:group$i /srv/home/user$i
    chown adsuser$i:adsgroup$i /srv/home/adsuser$i
    chown subuser$i:subgroup$i /srv/home/subuser$i
done
chmod 0700 /srv/home/*user*



export DEBIAN_FRONTEND=noninteractive

aptitude -y install samba winbind smbclient

systemctl disable samba-ad-dc.service
systemctl enable smbd.service
systemctl enable nmbd.service
systemctl enable winbind.service

systemctl stop samba-ad-dc.service
systemctl stop smbd.service
systemctl stop nmbd.service
systemctl stop winbind.service

rm -vf `find /var/ -name \*.tdb | grep samba`

cat > /etc/samba/smb.conf <<"EOF"
[global]
  realm = ADS.EXAMPLE.COM
  workgroup = ADS
  security = ADS
  idmap config * : range = 1000000-1999999
  idmap config subdom : schema_mode = rfc2307
  idmap config subdom : backend = ad
  idmap config subdom : range = 30001-40000
  idmap config ads : schema_mode = rfc2307
  idmap config ads : backend = ad
  idmap config ads : range = 20001-30000
  idmap config * : backend = tdb
[homes]
  read only = No
  path = /srv/home/%u
EOF


msktutil update --enctypes 0x10 --set-samba-secret

SID=`net rpc getsid -S adskdc01 |awk '{print $3}'`

systemctl start smbd.service
systemctl start nmbd.service
systemctl start winbind.service

sleep 5
set -x

wbinfo --name-to-sid adsuser11
wbinfo --name-to-sid adsgroup11
wbinfo --sid-to-uid ${SID}-1126
wbinfo --sid-to-gid ${SID}-1125
getent passwd adsuser11
getent group adsgroup11
