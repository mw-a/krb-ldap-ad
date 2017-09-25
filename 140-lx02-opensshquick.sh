#!/bin/sh
[ `hostname -s` != 'lx02' ] && exit 1

export DEBIAN_FRONTEND=noninteractive

aptitude -y install ssh

useradd -m adsuser

sed -i -e 's/^.*GSSAPIAuthentication.*$/GSSAPIAuthentication yes/' /etc/ssh/sshd_config

mkdir -p /var/run/sshd
/etc/init.d/ssh restart


export KRB5CCNAME=/tmp/krb5cc_opensshquick

echo 'P@ssw0rd' | kinit adsuser@ADS.EXAMPLE.COM
klist -s 
if [ $? != 0 ]; then

  echo 'P@ssw0rd' | kinit Administrator@ADS.EXAMPLE.COM  || \
    kinit Administrator@ADS.EXAMPLE.COM  

  aptitude -y install ldap-utils libsasl2-modules-gssapi-mit


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

" | ldapadd -c -Y GSSAPI -h adskdc01.ads.example.com  


  kdestroy
fi

sleep 1

echo 'P@ssw0rd' | kinit adsuser@ADS.EXAMPLE.COM

ssh -l adsuser lx02 'id ; hostname'
klist
kdestroy
