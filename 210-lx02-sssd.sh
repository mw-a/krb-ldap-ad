#!/bin/sh

[ `hostname -s` != 'lx02' ] && exit 1

export DEBIAN_FRONTEND=noninteractive

apt-get -y install -t testing sssd sssd-tools

cat > /etc/sssd/sssd.conf <<"EOF"
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
rm -vf /var/lib/sssd/*/*
systemctl start sssd
systemctl enable sssd
