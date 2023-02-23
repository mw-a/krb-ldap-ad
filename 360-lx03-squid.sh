#!/bin/bash

[ `hostname -s` != 'lx03' ] && exit 1

export DEBIAN_FRONTEND=noninteractive

apt-get -y install squid apache2-utils

#htpasswd -bc /etc/squid/passwd user P@ssw0rd


export KRB5CCNAME=/tmp/krb5cc_`basename $0`_adm_$$
echo P@ssw0rd | kinit Administrator
msktutil --create       --enctypes 0x10                          \
                  --use-service-account                  \
                   --service HTTP/lx03                   \
                   --service HTTP/lx03.subdom.ads.example.com   \
                   --keytab /etc/squid/krb5.keytab     \
                   --account-name srv-squid --user-creds-only --no-pac
kdestroy
chown proxy:proxy /etc/squid/krb5.keytab
chmod 0400 /etc/squid/krb5.keytab


cat > /etc/squid/squid.conf <<EOF
auth_param negotiate program /usr/lib/squid/negotiate_kerberos_auth -d -k /etc/squid/krb5.keytab
auth_param negotiate children 10
auth_param negotiate keep_alive on
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd


acl SSL_ports port 443
acl Safe_ports port 80         # http
acl Safe_ports port 443        # https
acl CONNECT method CONNECT

acl example_com_users proxy_auth REQUIRED
external_acl_type ad_proxy_group  ttl=3600  negative_ttl=3600 %LOGIN /usr/lib/squid/ext_kerberos_ldap_group_acl -g proxy-users -d
acl proxy_group external ad_proxy_group

http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access allow proxy_group
http_access deny all
http_port 3128
EOF

cat > /etc/default/squid <<EOF
KRB5_KTNAME=/etc/squid/krb5.keytab
export KRB5_KTNAME
EOF


systemctl restart squid
