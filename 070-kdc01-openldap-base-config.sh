#!/bin/sh

[ `hostname -s` != 'kdc01' ] && exit 1

export DEBIAN_FRONTEND=noninteractive
apt-get -y  purge slapd > /dev/null 2>&1


apt-get -y install slapd ldap-utils
systemctl stop slapd

rm -rvf /etc/ldap/slapd.d/  > /dev/null 2>&1
rm -vf /var/lib/ldap/*  > /dev/null 2>&1


sed -ie 's|^.*SLAPD_CONF.*$|SLAPD_CONF=/etc/ldap/slapd.conf|' /etc/default/slapd

cat > /etc/ldap/slapd.conf <<"EOF"
include /etc/ldap/schema/core.schema
include /etc/ldap/schema/cosine.schema
include /etc/ldap/schema/inetorgperson.schema
include /etc/ldap/schema/nis.schema

pidfile /var/run/slapd/slapd.pid
argsfile /var/run/slapd/slapd.args

modulepath /usr/lib/ldap
moduleload back_mdb

database mdb
suffix dc=example,dc=com
access to * by * read
rootdn cn=root,dc=example,dc=com
rootpw P@ssw0rd

EOF

systemctl start slapd.service 

sleep 5

cat > /tmp/dit.ldif <<"EOF"
dn: dc=example,dc=com
objectClass: top
objectClass: organization
objectClass: dcObject
o: example
dc: example

dn: ou=people,dc=example,dc=com
objectClass: top
objectClass: organizationalUnit
ou: people

dn: ou=groups,dc=example,dc=com
objectClass: top
objectClass: organizationalUnit
ou: groups

EOF

ldapadd -H ldap://kdc01.example.com -D cn=root,dc=example,dc=com -w P@ssw0rd -f /tmp/dit.ldif
