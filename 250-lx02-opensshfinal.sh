[ `hostname -s` != 'lx02' ] && exit 1

for i in `seq -w 1 99`; do
    mkdir -p /srv/home/user$i /srv/home/adsuser$i /srv/home/subuser$i
    chown user$i:group$i /srv/home/user$i
    chown adsuser$i:adsgroup$i /srv/home/adsuser$i
    chown subuser$i:subgroup$i /srv/home/subuser$i
done
chmod 0700 /srv/home/*user*
										   


export DEBIAN_FRONTEND=noninteractive

apt-get -y install ssh

cat > /etc/ssh/ssh_config <<"EOF"
Host *
SendEnv LANG LC_*
HashKnownHosts yes
GSSAPIAuthentication yes
GSSAPIDelegateCredentials yes
#GSSAPIRenewalForcesRekey yes
GSSAPIKeyExchange yes
EOF

sed -i -e 's/^GSSAPI.*$//' /etc/ssh/sshd_config

cat >>  /etc/ssh/sshd_config <<EOF
GSSAPIAuthentication yes
GSSAPIKeyExchange yes
GSSAPICleanupCredentials yes
GSSAPIStoreCredentialsOnRekey yes
EOF

cat > /etc/krb5.conf <<"EOF"
[libdefaults]
  default_realm = ADS.EXAMPLE.COM
  forwardable = true
[realms]
  EXAMPLE.COM = {
    kdc = kdc01.example.com
    admin_server = kdc01.example.com
  }
  ADS.EXAMPLE.COM = {
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

