#!/bin/sh

[ `hostname -s` != 'lx01' ] && exit 1

/sbin/hwclock --systohc

export DEBIAN_FRONTEND=noninteractive

aptitude -y install krb5-user krb5-doc

cat > /etc/krb5.conf <<EOF
[libdefaults]
  default_realm = EXAMPLE.COM
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
EOF

kadmin -p user/admin@EXAMPLE.COM <<EOF
P@ssw0rd
listprincs
add_policy -maxlife 180days -minlife 1day -minlength 6 -minclasses 2 -history 10 default
addprinc -randkey host/lx01.example.com
ktadd -k /etc/krb5.keytab host/lx01.example.com@EXAMPLE.COM
quit
EOF
