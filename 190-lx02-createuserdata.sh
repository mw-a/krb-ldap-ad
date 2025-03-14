#!/bin/bash
[ `hostname -s` != 'lx02' ] && exit 1

export DEBIAN_FRONTEND=noninteractive

apt-get -y install ldap-utils libsasl2-modules-gssapi-mit

export KRB5CCNAME=/tmp/krb5cc_create_ads_userdata.sh

echo 'P@ssw0rd' | kinit Administrator@ADS.EXAMPLE.COM  || \
  kinit Administrator@ADS.EXAMPLE.COM

klist -s
if [ $? != 0 ]; then
  echo ERROR &>2
  exit 1
fi


(for i in {10..99} ; do

echo "dn: cn=adsgroup${i},cn=users,dc=ads,dc=example,dc=com
objectClass: Group
cn: adsgroup${i}
sAMAccountName: adsgroup${i}
msSFU30Name:  adsgroup${i}
msSFU30NisDomain: ads
gidNumber: $((i + 20000))
memberUid: adsuser${i}

dn: cn=adsuser${i},cn=users,dc=ads,dc=example,dc=com
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: user
cn: adsuser${i}
sn: adsuser${i}
givenName: adsuser${i}
instanceType: 4
displayName: ADS User${i}
name: ADS User${i}
userAccountControl: 512
sAMAccountName: adsuser${i}
userPrincipalName: adsuser${i}@ADS.EXAMPLE.COM
unicodePwd:: IgBQAEAAcwBzAHcAMAByAGQAIgA=
msSFU30Name: adsuser${i}
msSFU30NisDomain: ads
uid: adsuser${i}
uidNumber: $((i + 20000))
gidNumber: $((i + 20000))
unixHomeDirectory: /nfshome/adsuser${i}
loginShell: /bin/bash
homeDirectory: \\\\\\\\lx02\\\\adsuser${i}
homeDrive: x:
"

done ) | ldapadd -c -Y GSSAPI -H ldap://adskdc01.ads.example.com

kdestroy

