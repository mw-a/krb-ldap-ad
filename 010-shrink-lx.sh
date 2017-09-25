#/bin/bash
dd if=/dev/zero of=/bigfile ; rm -vf /bigfile

vmware-toolbox-cmd disk wipe /

cat /etc/fstab | grep -v swap > /etc/fstab$$ && echo /dev/sda5 none swap defaults 0 0 >> /etc/fstab$$ ; cat  /etc/fstab$$ > /etc/fstab ; rm -vf /etc/fstab$$

swapoff /dev/sda5
dd if=/dev/zero of=/dev/sda5
mkswap /dev/sda5
reboot
