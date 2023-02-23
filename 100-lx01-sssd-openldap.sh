#!/bin/sh
[ `hostname -s` != 'lx01'  ] && exit 1

export DEBIAN_FRONTEND=noninteractive

apt-get -y install sssd sssd-tools

cat > /etc/sssd/sssd.conf <<"EOF"
[sssd]
config_file_version = 2
services = nss, pam
domains = EXAMPLE.COM
[domain/EXAMPLE.COM]
id_provider = ldap
ldap_uri = ldap://kdc01.example.com
ldap_search_base = dc=example,dc=com
ldap_schema = rfc2307bis
auth_provider = krb5
krb5_realm = EXAMPLE.COM
krb5_server = kdc01.example.com
krb5_validate = true
EOF
chmod 0600 /etc/sssd/sssd.conf
systemctl restart sssd
getent passwd user54
getent group group54
id user54
id user55
id user77

