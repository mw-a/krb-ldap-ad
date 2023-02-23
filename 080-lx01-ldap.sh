#!/bin/sh
#!/bin/sh
[ `hostname -s` != 'lx01'  ] && exit 1

export DEBIAN_FRONTEND=noninteractive

apt-get -y install ldap-utils

cat >  /etc/ldap/ldap.conf <<"EOF"
BASE dc=example,dc=com
URI ldap://kdc01.example.com
EOF

ldapsearch -xLLL '(objectClass=*)' cn
ldapsearch -xLLL -D cn=root,dc=example,dc=com  -w P@ssw0rd '(objectClass=*)' cn


