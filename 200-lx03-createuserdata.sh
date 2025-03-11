#!/bin/bash
[ `hostname -s` != 'lx03' ] && exit 1

export DEBIAN_FRONTEND=noninteractive

apt-get -y install ldap-utils libsasl2-modules-gssapi-mit

export KRB5CCNAME=/tmp/krb5cc_create_ads_userdata.sh

echo 'P@ssw0rd' | kinit Administrator@SUBDOM.ADS.EXAMPLE.COM  || \
  kinit Administrator@SUBDOM.ADS.EXAMPLE.COM

klist -s
if [ $? != 0 ]; then
  echo ERROR &>2
  exit 1
fi


(for i in {10..99} ; do

echo "dn: cn=subgroup${i},cn=users,dc=subdom,dc=ads,dc=example,dc=com
objectClass: Group
cn: subgroup${i}
sAMAccountName: subgroup${i}
msSFU30Name:  subgroup${i}
msSFU30NisDomain: ads
gidNumber: $((i + 30000))
memberUid: subuser${i}

dn: cn=subuser${i},cn=users,dc=subdom,dc=ads,dc=example,dc=com
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: user
cn: subuser${i}
sn: subuser${i}
givenName: subuser${i}
instanceType: 4
displayName: ADS User${i}
name: ADS User${i}
userAccountControl: 512
sAMAccountName: subuser${i}
userPrincipalName: subuser${i}@ADS.EXAMPLE.COM
unicodePwd:: IgBQAEAAcwBzAHcAMAByAGQAIgA=
msSFU30Name: subuser${i}
msSFU30NisDomain: ads
uid: subuser${i}
uidNumber: $((i + 30000))
gidNumber: $((i + 30000))
unixHomeDirectory: /nfshome/subuser${i}
loginShell: /bin/bash
homeDirectory: \\\\\\\\lx02\\\\subuser${i}
homeDrive: x:
"

done ) | ldapadd -c -Y GSSAPI -H ldap://adskdc02.subdom.ads.example.com

kdestroy
