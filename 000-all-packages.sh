#!/bin/bash

systemctl disable apt-daily.timer
systemctl stop apt-daily.timer

###export DEBIAN_FRONTEND=noninteractive

cat > /etc/apt/sources.list <<EOF
deb http://ftp.de.debian.org/debian/ stretch main
deb-src http://ftp.de.debian.org/debian/ stretch main

deb http://security.debian.org/ stretch/updates main
deb-src http://security.debian.org/ stretch/updates main
EOF

aptitude -y purge firefox 

aptitude update && \
aptitude -y dist-upgrade && \
apt autoremove && \
aptitude clean && \
aptitude -y purge libnss-myhostname && \
aptitude -y purge unattended-upgrades && \
aptitude -y install firefox-esr
aptitude install -y -d ssh samba ldap-utils libsasl2-modules-gssapi-mit    \
   libnss-ldapd libpam-krb5 apache2 libapache2-mod-auth-kerb nfs-common    \
   nfs-kernel-server krb5-user krb5-doc krb5-admin-server krb5-kdc         \
   krb5-pkinit  wireshark winbind sssd sssd-tools                          \
   krb5-kdc-ldap  krb5-k5tls krb5-kpropd krb5-otp slapd unixodbc                 \
   vim sssd sssd-ad libpam-sss libnss-sss                                  \
   openjdk-8-demo openjdk-8-doc openjdk-8-jdk openjdk-8-jre                \
   sasl2-bin autoconf                                                      \
   curl smbclient libkrb5-dev libldap-dev g++ git-core bison kstart        \
   libapache2-mod-auth-gssapi libsasl2-dev emacs emacs-nox msktutil autofs

