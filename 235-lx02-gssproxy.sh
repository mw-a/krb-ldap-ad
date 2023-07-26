[ `hostname -s` != 'lx02' ] && exit 1

export DEBIAN_FRONTEND=noninteractive

apt-get -y install gssproxy msktutil

cat > /etc/krb5.conf <<EOF
[libdefaults]
  default_realm = ADS.EXAMPLE.COM
  forwardable = true
[realms]
  EXAMPLE.COM = {
    kdc = kdc01.example.com
    admin_server = kdc01.example.com
  }
[domain_realm]
  example.com = EXAMPLE.COM
  .example.com = EXAMPLE.COM
  ads.example.com = ADS.EXAMPLE.COM
  .ads.example.com = ADS.EXAMPLE.COM
  subdom.ads.example.com = SUBDOM.ADS.EXAMPLE.COM
  .subdom.ads.example.com = SUBDOM.ADS.EXAMPLE.COM
EOF

echo P@ssw0rd | kinit Administrator
msktutil create --use-service-account --service gssproxy/lx02 --keytab /etc/gssproxy/krb5.keytab --account-name srv-gssproxy

ldapmodify -H ldap://adskdc01 << EOF
dn: cn=srv-gssproxy,cn=users,dc=ads,dc=example,dc=com
changetype: modify
replace: userAccountControl
userAccountControl: 16777728
-
replace: msDS-AllowedToDelegateTo
msDS-AllowedToDelegateTo: ldap/ADSKDC01
msDS-AllowedToDelegateTo: ldap/ADSKDC01/ADS
msDS-AllowedToDelegateTo: ldap/adskdc01.ads.example.com
msDS-AllowedToDelegateTo: ldap/adskdc01.ads.example.com/ADS
msDS-AllowedToDelegateTo: ldap/adskdc01.ads.example.com/ads.example.com

EOF

kdestroy -A

cat > /etc/gssproxy/90-ldapsearch.conf <<EOF
[service/ldapsearch]
mechs = krb5
cred_store = keytab:/etc/gssproxy/krb5.keytab
cred_store = ccache:FILE:/var/lib/gssproxy/clients/krb5cc_%U
cred_usage = initiate
allow_any_uid = yes
trusted = yes
impersonate = yes
euid = 0
program = /usr/bin/ldapsearch
EOF

systemctl enable gssproxy
systemctl restart gssproxy

su - adsuser42 -c "kdestroy"
su - adsuser32 -c "GSS_USE_PROXY=yes ldapsearch -H ldap://adskdc01 -LLL -b dc=ads,dc=example,dc=com samaccountname=adsuser42 cn"
