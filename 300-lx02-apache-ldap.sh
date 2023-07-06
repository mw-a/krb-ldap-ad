[ `hostname -s` != 'lx02' ] && exit 1

a2enmod authnz_ldap.load

cat > /etc/apache2/sites-available/default-krb5.conf <<"EOF"
<VirtualHost *:80>
    DocumentRoot /var/www/html
    ErrorLog ${APACHE_LOG_DIR}/krb5-error.log
    CustomLog ${APACHE_LOG_DIR}/krb5-access.log combined
<Location />
    AuthType GSSAPI
    AuthName "GSSAPI Single Sign On Login"
    GssapiCredStore keytab:/etc/apache2/krb5.keytab
    #require valid-user
    AuthLDAPURL "ldap://adskdc01.ads.example.com/dc=ads,dc=example,dc=com?userPrincipalName?sub"
    AuthLDAPBindDN "CN=adsuser99,CN=Users,DC=ads,DC=example,DC=com"
    AuthLDAPBindPassword "P@ssw0rd"
    AuthLDAPRemoteUserAttribute "userPrincipalName"
    require ldap-group CN=WWW,CN=Users,DC=ADS,DC=EXAMPLE,DC=COM
</Location>
</VirtualHost>
EOF

systemctl restart apache2

export KRB5CCNAME=/tmp/krb5cc_$$
echo P@ssw0rd | kinit Administrator

ldapadd -H ldap://adskdc01.ads.example.com <<EOF
dn: CN=www,CN=Users,DC=ads,DC=example,DC=com
objectClass: top
objectClass: group
cn: www
sAMAccountName: www
member: CN=adsuser99,CN=Users,DC=ads,DC=example,DC=com
member: CN=adsuser89,CN=Users,DC=ads,DC=example,DC=com
member: CN=adsuser79,CN=Users,DC=ads,DC=example,DC=com
member: CN=adsuser69,CN=Users,DC=ads,DC=example,DC=com

EOF
kdestroy
