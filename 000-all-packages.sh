#!/bin/bash -e

systemctl disable apt-daily.timer
systemctl stop apt-daily.timer

apt-get -y purge unattended-upgrades packagekit libnss-myhostname firefox

export DEBIAN_FRONTEND=noninteractive

apt-get update -o Acquire::Check-Valid-Until=false
apt-get -y autoremove --purge
apt-get -y dist-upgrade
apt-get -y autoremove --purge
apt-get clean
apt-get -y install firefox-esr

apt-get install -y -d ssh samba ldap-utils libsasl2-modules-gssapi-mit     \
   libnss-ldapd libpam-krb5 apache2 libapache2-mod-auth-gssapi nfs-common  \
   nfs-kernel-server krb5-user krb5-doc krb5-admin-server krb5-kdc         \
   krb5-pkinit wireshark winbind sssd sssd-tools                           \
   krb5-kdc-ldap krb5-k5tls krb5-kpropd krb5-otp slapd unixodbc            \
   vim sssd sssd-ad libpam-sss libnss-sss                                  \
   openjdk-11-demo openjdk-11-doc openjdk-11-jdk openjdk-11-jre            \
   sasl2-bin autoconf                                                      \
   curl smbclient libkrb5-dev libldap2-dev g++ git bison kstart            \
   libapache2-mod-auth-gssapi libsasl2-dev emacs emacs-nox msktutil adcli  \
   autofs gssproxy

echo deb https://snapshot.debian.org/archive/debian/20210925T203230Z/ testing main > /etc/apt/sources.list.d/testing.list
apt-get update -o Acquire::Check-Valid-Until=false
cat << EOF > /etc/apt/preferences.d/testing
Package: *
Pin: release a=testing
Pin-Priority: 250
EOF

apt-get install -y -d -t testing sssd sssd-tools
