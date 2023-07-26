#!/bin/sh

[ `hostname -s` != 'lx01' ] && exit 1

export DEBIAN_FRONTEND=noninteractive

apt-get -y install sssd sssd-tools

cat > /etc/sssd/sssd.conf <<EOF
[sssd]
config_file_version = 2
services = nss, pam
domains = EXAMPLE.COM, ADS.EXAMPLE.COM

[domain/EXAMPLE.COM]
id_provider = ldap
ldap_uri = ldap://kdc01.example.com
ldap_search_base = dc=example,dc=com
ldap_schema = rfc2307bis
min_id = 10001
max_id = 20000
auth_provider = krb5
krb5_realm = EXAMPLE.COM
krb5_server = kdc01.example.com
krb5_validate = true

[domain/ADS.EXAMPLE.COM]
id_provider = ad
min_id = 20001
max_id = 40000
auth_provider = ad
ldap_id_mapping = False

[domain/ADS.EXAMPLE.COM/SUBDOM.ADS.EXAMPLE.COM]
use_fully_qualified_names = False
EOF
chmod 0600 /etc/sssd/sssd.conf

systemctl stop sssd

KRB5CCNAME=/tmp/krb5cc_`basename $0`$$
echo P@ssw0rd |kinit Administrator@ADS.EXAMPLE.COM

echo "dn: cn=lx01,cn=computers,dc=ads,dc=example,dc=com
changetype: delete

" | ldapadd -c -Y GSSAPI -h adskdc01.ads.example.com   2>/dev/null

echo "dn: cn=lx01,cn=computers,dc=ads,dc=example,dc=com
changetype: add
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: user
objectClass: computer
cn: lx01
instanceType: 4
name: lx01
userAccountControl: 4128
sAMAccountName: LX01\$
altSecurityIdentities: Kerberos:host/lx01.example.com@EXAMPLE.COM

" | ldapadd -c -Y GSSAPI -h adskdc01.ads.example.com
kdestroy

sleep 3

rm -vf /var/lib/sssd/*/*

systemctl start sssd
systemctl enable sssd
