[ `hostname -s` != 'lx03' ] && exit 1

export DEBIAN_FRONTEND=noninteractive

apt-get -y install ssh

cat > /etc/ssh/ssh_config.d/gssapi.conf <<"EOF"
GSSAPIAuthentication yes
GSSAPIDelegateCredentials yes
GSSAPIRenewalForcesRekey yes
GSSAPIKeyExchange yes
EOF

cat > /etc/ssh/sshd_config.d/gssapi.conf <<EOF
GSSAPIAuthentication yes
GSSAPIKeyExchange yes
GSSAPICleanupCredentials yes
GSSAPIStoreCredentialsOnRekey yes
EOF

cat > /etc/krb5.conf <<"EOF"
[libdefaults]
  default_realm = SUBDOM.ADS.EXAMPLE.COM
  forwardable = true
[realms]
  EXAMPLE.COM = {
    kdc = kdc01.example.com
    admin_server = kdc01.example.com
  }
  SUBDOM.ADS.EXAMPLE.COM = {
    auth_to_local = RULE:[1:$1@$0](^.*@EXAMPLE.COM$)s/@.*//
    auth_to_local = RULE:[1:$1@$0](^.*@ADS.EXAMPLE.COM$)s/@.*//
    auth_to_local = RULE:[1:$1@$0](^.*@SUBDOM.ADS.EXAMPLE.COM$)s/@.*//
    auth_to_local = DEFAULT
  }

[domain_realm]
  example.com = EXAMPLE.COM
  .example.com = EXAMPLE.COM
  ads.example.com = ADS.EXAMPLE.COM
  .ads.example.com = ADS.EXAMPLE.COM
  subdom.ads.example.com = SUBDOM.ADS.EXAMPLE.COM
  .subdom.ads.example.com = SUBDOM.ADS.EXAMPLE.COM
EOF

systemctl restart ssh.service
