#!/bin/sh
[ `hostname -s` != 'kdc01' ] && exit 1

/sbin/hwclock --systohc

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

DEBIAN_FRONTEND=noninteractive apt-get -y install krb5-user krb5-doc krb5-kdc krb5-admin-server


/etc/init.d/krb5-kdc stop
/etc/init.d/krb5-admin-server stop

cat > /etc/krb5kdc/kdc.conf <<EOF
[realms]
  EXAMPLE.COM = {
    database_name = /var/lib/krb5kdc/principal
    acl_file = /etc/krb5kdc/kadm5.acl
    key_stash_file = /etc/krb5kdc/stash
    max_life = 10h 0m 0s
    max_renewable_life = 7d 0h 0m 0s
    master_key_type = aes256-cts
    supported_enctypes = aes256-cts:normal camellia256-cts-cmac:normal
    default_principal_flags = +preauth
  }
EOF

kdb5_util create -s EXAMPLE.COM <<EOF
P@ssw0rd
P@ssw0rd
EOF

kadmin.local <<EOF
addprinc user@EXAMPLE.COM
P@ssw0rd
P@ssw0rd
addprinc user/admin@EXAMPLE.COM
P@ssw0rd
P@ssw0rd
addprinc -randkey host/kdc01.example.com@EXAMPLE.COM
EOF

/etc/init.d/krb5-kdc start

echo 'P@ssw0rd' | kinit user@EXAMPLE.COM
kvno host/kdc01.example.com@EXAMPLE.COM
klist
kdestroy
