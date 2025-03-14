#!/bin/bash -e

systemctl disable apt-daily.timer
systemctl stop apt-daily.timer

apt-get -y purge unattended-upgrades packagekit libnss-myhostname firefox

# remove old kernel left by installer
apt-get -y purge $(dpkg-query -W -f='${Package}\n' linux-image-[0-9].* | head -1)

export DEBIAN_FRONTEND=noninteractive

apt-get update
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
   default-jdk screen tmux strace                                          \
   sasl2-bin autoconf                                                      \
   curl smbclient libkrb5-dev libldap2-dev g++ git bison kstart            \
   libapache2-mod-auth-gssapi libsasl2-dev emacs emacs-nox msktutil adcli  \
   autofs gssproxy
