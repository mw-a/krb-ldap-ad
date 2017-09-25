#!/bin/sh
[ `hostname -s` != 'lx03' ] && exit 1
export DEBIAN_FRONTEND=noninteractive
/sbin/hwclock --systohc
aptitude  -y install krb5-user krb5-doc libsasl2-modules-gssapi-mit msktutil

cat > /etc/krb5.conf <<EOF
[libdefaults]
  default_realm = SUBDOM.ADS.EXAMPLE.COM
[realms]
  EXAMPLE.COM = {
    kdc = kdc01.example.com
    admin_server = kdc01.example.com
  }
[domain_realm]
  example.com = EXAMPLE.COM
  .example.com = EXAMPLE.COM
  ads.example.com = ADS.EXAMPLE.COM
  .ads.example.com = ADS.EXAMPLE.COM
  subdom.ads.example.com = SUBDOM.ADS.EXAMPLE.COM
  .subdom.ads.example.com = SUBDOM.ADS.EXAMPLE.COM
  subdom.ads.example.com = SUBDOM.ADS.EXAMPLE.COM
  .subdom.ads.example.com = SUBDOM.ADS.EXAMPLE.COM
EOF


echo P@ssw0rd | kinit Administrator

msktutil create --enctypes 0x10

kinit -k 'lx03$@SUBDOM.ADS.EXAMPLE.COM'
kvno -k /etc/krb5.keytab host/lx03.subdom.ads.example.com@SUBDOM.ADS.EXAMPLE.COM
klist
kdestroy
