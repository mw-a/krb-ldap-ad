#!/bin/sh
[ `hostname -s` != 'lx02' ] && exit 1

export DEBIAN_FRONTEND=noninteractive

apt-get -y install ssh

useradd -m adsuser

echo GSSAPIAuthentication yes > /etc/ssh/sshd_config.d/gssapi.conf

mkdir -p /var/run/sshd
/etc/init.d/ssh restart


export KRB5CCNAME=/tmp/krb5cc_opensshquick

echo 'P@ssw0rd' | kinit adsuser@ADS.EXAMPLE.COM
klist -s
if [ $? != 0 ]; then

  echo 'P@ssw0rd' | kinit Administrator@ADS.EXAMPLE.COM  || \
    kinit Administrator@ADS.EXAMPLE.COM

  apt-get -y install ldap-utils libsasl2-modules-gssapi-mit


  echo "dn: cn=adsuser,cn=users,dc=ads,dc=example,dc=com
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: user
cn: adsuser
instanceType: 4
userAccountControl: 512
sAMAccountName: adsuser
userPrincipalName: adsuser@ADS.EXAMPLE.COM
unicodePwd:: IgBQAEAAcwBzAHcAMAByAGQAIgA=

" | ldapadd -c -Y GSSAPI -H ldap://adskdc01.ads.example.com


  kdestroy
fi

sleep 1

echo 'P@ssw0rd' | kinit adsuser@ADS.EXAMPLE.COM

ssh -l adsuser lx02 'id ; hostname'
klist
kdestroy
