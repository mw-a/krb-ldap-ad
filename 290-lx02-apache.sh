[ `hostname -s` != 'lx02' ] && exit 1

export DEBIAN_FRONTEND=noninteractive

apt-get -y install apache2 libapache2-mod-auth-gssapi curl msktutil

echo Testpage > /var/www/html/index.html

cat > /usr/lib/cgi-bin/krb5-test.cgi <<"EOF"
#!/bin/bash
echo "Content-type: text/plain"
echo ""
echo "Hallo, $REMOTE_USER"
EOF

chmod +x /usr/lib/cgi-bin/krb5-test.cgi

curl http://lx02.ads.example.com/index.html

systemctl stop apache2 > /dev/null 2>&1


export KRB5CCNAME=/tmp/krb5cc_`basename $0`_adm_$$
echo P@ssw0rd | kinit Administrator
msktutil --create       --enctypes 0x10                          \
                  --use-service-account                  \
                   --service HTTP/lx02                   \
                   --service HTTP/lx02.ads.example.com   \
                   --keytab /etc/apache2/krb5.keytab     \
                   --account-name srv-http --user-creds-only
kdestroy
chown www-data:www-data /etc/apache2/krb5.keytab
chmod 0400 /etc/apache2/krb5.keytab

cat > /etc/apache2/sites-available/default-krb5.conf <<"EOF"
<VirtualHost *:80>
    DocumentRoot /var/www/html
    ErrorLog ${APACHE_LOG_DIR}/krb5-error.log
    CustomLog ${APACHE_LOG_DIR}/krb5-access.log combined
<Location />
    AuthType GSSAPI
    AuthName "GSSAPI Single Sign On Login"
    GssapiCredStore keytab:/etc/apache2/krb5.keytab
    require valid-user
</Location>
</VirtualHost>
EOF
a2ensite default-krb5
a2dissite 000-default
a2enconf serve-cgi-bin
a2enmod cgi
apachectl -t
systemctl start apache2

sleep 3

curl http://lx02.ads.example.com/index.html


export KRB5CCNAME=/tmp/krb5cc_`basename $0`$$
echo P@ssw0rd | kinit adsuser33
curl --negotiate -u: http://lx02.ads.example.com/index.html
curl --negotiate -u: http://lx02.ads.example.com/cgi-bin/krb5-test.cgi

klist
kdestroy

