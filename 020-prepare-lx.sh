#/bin/bash

apt autoremove

grub-install /dev/sda
mkinitramfs  -o /boot/initrd.img-`uname -r` `uname -r` 

rm -rvf /home/local
echo "alias ll='ls -la'" >> /root/.bashrc 
chown user:user /home/user
chmod 0700 /home/*
rm -vf /home/user/*  /home/user/.bash_history
rm -rvf /root/ftp* /root/* /root/.ssh /root/.bash_history /tmp/* /tmp/.??* /var/tmp/* /var/tmp/.??* 

echo s > /proc/sysrq-trigger
echo u > /proc/sysrq-trigger


echo 'now poweroff and export to ovf'
sleep 10

poweroff -f




