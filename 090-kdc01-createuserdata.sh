#!/bin/bash
[ `hostname -s` != 'kdc01' ] && exit 1

(for i in {10..99} ; do

echo "dn: cn=group${i},ou=groups,dc=example,dc=com
objectClass: posixGroup
cn: group${i}
gidNumber: $((i + 10000))

dn: cn=user${i},ou=people,dc=example,dc=com
objectclass: person
objectclass: organizationalPerson
objectclass: inetOrgPerson
objectclass: posixAccount
cn: user${i}
sn: user${i}
givenname: user${i}
uid: user${i}
uidNumber: $((i + 10000))
gidNumber: $((i + 10000))
gecos: Example user $i
homeDirectory: /nfshome/user${i}
loginShell: /bin/bash
"

done ) | ldapadd -H ldap://localhost -D cn=root,dc=example,dc=com -w P@ssw0rd

(for i in {10..99} ; do
  echo add_principal -pw P@ssw0rd user$i
done ) | kadmin.local




