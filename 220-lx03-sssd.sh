#!/bin/sh

[ `hostname -s` != 'lx03' ] && exit 1

export DEBIAN_FRONTEND=noninteractive

apt-get -y install sssd sssd-tools

cat > /etc/sssd/sssd.conf <<"EOF"
[sssd]
config_file_version = 2
services = nss, pam
domains = EXAMPLE.COM, ADS.EXAMPLE.COM, SUBDOM.ADS.EXAMPLE.COM


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
id_provider = ldap
ldap_uri = ldap://adskdc01.ads.example.com
ldap_search_base = dc=ads,dc=example,dc=com
ldap_schema = rfc2307bis
ldap_sasl_mech = GSSAPI
min_id = 20001
max_id = 30000
auth_provider = krb5
krb5_realm = ADS.EXAMPLE.COM
krb5_server = adskdc01.ads.example.com
ldap_group_object_class = Group
ldap_user_object_class = User
ldap_user_home_directory = unixHomeDirectory
krb5_validate = true
ldap_sasl_authid = lx03$@SUBDOM.ADS.EXAMPLE.COM

[domain/SUBDOM.ADS.EXAMPLE.COM]
id_provider = ldap
ldap_uri = ldap://adskdc02.subdom.ads.example.com
ldap_search_base = dc=subdom,dc=ads,dc=example,dc=com
ldap_schema = rfc2307bis
ldap_sasl_mech = GSSAPI
#min_id = 30001
#max_id = 40000
auth_provider = krb5
krb5_realm = SUBDOM.ADS.EXAMPLE.COM
krb5_server = adskdc02.subdom.ads.example.com
ldap_group_object_class = Group
ldap_user_object_class = User
ldap_user_home_directory = unixHomeDirectory
krb5_validate = true
ldap_sasl_authid = lx03$@SUBDOM.ADS.EXAMPLE.COM

EOF
chmod 0600 /etc/sssd/sssd.conf

systemctl stop sssd
rm -vf /var/lib/sssd/*/*
systemctl start sssd
systemctl enable sssd
