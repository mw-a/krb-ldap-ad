#!/bin/sh
[ `hostname -s` != 'lx01'  ] && exit 1

export DEBIAN_FRONTEND=noninteractive

aptitude -y install ssh

kadmin -p user/admin@EXAMPLE.COM <<EOF
P@ssw0rd
addprinc -pw P@ssw0rd user01
addprinc -pw P@ssw0rd user02
addprinc -pw P@ssw0rd user03
EOF
useradd -m user
useradd -m user01
useradd -m user02
useradd -m user03

sed -i -e 's/^.*GSSAPIAuthentication.*$/GSSAPIAuthentication yes/' /etc/ssh/sshd_config

mkdir -p /var/run/sshd
/etc/init.d/ssh restart

echo 'P@ssw0rd' | kinit user@EXAMPLE.COM
ssh -l user lx01 'id ; hostname'
klist
kdestroy
