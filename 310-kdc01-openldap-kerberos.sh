#!/bin/sh

[ `hostname -s` != 'kdc01' ] && exit 1

systemctl stop slapd.service


apt-get -y install ldap-utils libsasl2-modules-gssapi-mit

grep authz-regexp /etc/ldap/slapd.conf > /dev/null
if [ $? != 0 ]; then
  sed -i -e 's|^include */etc/ldap/schema/nis.schema *$|include /etc/ldap/schema/nis.schema\n\nauthz-regexp uid=.*/admin,cn=gss.*,cn=auth cn=admin,dc=example,dc=com|' /etc/ldap/slapd.conf
fi

systemctl start slapd.service 

kadmin.local -q 'addprinc -randkey ldap/kdc01.example.com'
/bin/rm -vf /etc/ldap/krb5.keytab
kadmin.local -q 'ktadd -k /etc/ldap/krb5.keytab ldap/kdc01.example.com@EXAMPLE.COM'

chown openldap:openldap /etc/ldap/krb5.keytab

sed -ie 's|^.*KRB5_KTNAME.*$|export KRB5_KTNAME=/etc/ldap/krb5.keytab|' /etc/default/slapd
systemctl restart slapd.service


systemctl restart slapd.service
