#!/bin/sh

[ `hostname -s` != 'kdc01' ] && exit 1

export DEBIAN_FRONTEND=noninteractive


systemctl stop krb5-kdc
systemctl stop krb5-admin-server

if [ -r /root/example.com.dump ]; then
  echo "WARNING: /root/example.com.dump exists >&2"
  sleep 2
else
  kdb5_util dump /root/example.com.dump
fi

kdb5_util destroy -f

cat >  /etc/krb5kdc/kdc.conf <<"EOF"
[realms]
  EXAMPLE.COM = {
    database_module = openldap_ldapconf
    acl_file = /etc/krb5kdc/kadm5.acl
    key_stash_file = /etc/krb5kdc/stash
    max_life = 10h 0m 0s
    max_renewable_life = 7d 0h 0m 0s
    master_key_type = aes256-cts
    supported_enctypes = aes256-cts:normal camellia256-cts-cmac:normal
    default_principal_flags = +preauth
  }

[dbmodules]
  openldap_ldapconf = {
    db_library = kldap
    ldap_kerberos_container_dn = "cn=mit-kerberos,dc=example,dc=com"  
    ldap_kdc_dn = "cn=mit-kdc,cn=mit-kerberos,dc=example,dc=com"
    ldap_kadmind_dn = "cn=mit-kadmind,cn=mit-kerberos,dc=example,dc=com"
    ldap_service_password_file = "/etc/krb5kdc/service.keyfile"
    ldap_servers = "ldap://127.0.0.1/"
    ldap_conns_per_server = 5
  }
EOF

cat > /tmp/kerberos-entries.ldif <<"EOF"
dn: cn=mit-kerberos,dc=example,dc=com
changetype: add
objectClass: krbContainer
cn: mit-kerberos

dn: cn=mit-kdc,cn=mit-kerberos,dc=example,dc=com
changetype: add
objectClass: organizationalRole
objectClass: simpleSecurityObject
cn: mit-kdc
userPassword: {SSHA}PcN8RktnLvNnLQSuZV+Zj+1JwLGWaj34

dn: cn=mit-kadmind,cn=mit-kerberos,dc=example,dc=com
changetype: add
objectClass: organizationalRole
objectClass: simpleSecurityObject
cn: mit-kadmind
userPassword: {SSHA}PcN8RktnLvNnLQSuZV+Zj+1JwLGWaj34

EOF

ldapadd -QH ldapi:/// -Y EXTERNAL -f /tmp/kerberos-entries.ldif

cat > /tmp/kerberos-updates.ldif <<"EOF"
dn: cn=LDAP Read Write,ou=groups,dc=example,dc=com
changetype: modify
add: member
member: cn=mit-kdc,cn=mit-kerberos,dc=example,dc=com
member: cn=mit-kadmind,cn=mit-kerberos,dc=example,dc=com

EOF

ldapmodify -QH ldapi:/// -Y EXTERNAL -f /tmp/kerberos-updates.ldif


kdb5_ldap_util create                                          \
                -D cn=admin,dc=example,dc=com -w P@ssw0rd      \
                -r EXAMPLE.COM -s -sscope sub                  \
                -subtrees ou=people,dc=example,dc=com <<EOF
P@ssw0rd
P@ssw0rd
EOF

kdb5_ldap_util stashsrvpw                        \
                -D cn=admin,dc=example,dc=com                  \
                -f /etc/krb5kdc/service.keyfile                \
                cn=mit-kdc,cn=mit-kerberos,dc=example,dc=com <<EOF
P@ssw0rd
P@ssw0rd
P@ssw0rd
EOF

kdb5_ldap_util stashsrvpw                        \
                -D cn=admin,dc=example,dc=com                  \
                -f /etc/krb5kdc/service.keyfile                \
                cn=mit-kadmind,cn=mit-kerberos,dc=example,dc=com <<EOF
P@ssw0rd
P@ssw0rd
P@ssw0rd
EOF

kdb5_util -update load /root/example.com.dump

systemctl start krb5-kdc
systemctl start krb5-admin-server
