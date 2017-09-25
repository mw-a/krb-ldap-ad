#!/bin/sh
[ `hostname -s` != 'kdc01' ] && exit 1
cat >  /etc/krb5kdc/kadm5.acl  <<EOF
*/admin@EXAMPLE.COM *
EOF

/etc/init.d/krb5-admin-server stop > /dev/null 2>&1
/etc/init.d/krb5-admin-server start
