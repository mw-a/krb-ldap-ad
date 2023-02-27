#/bin/bash -e
dd if=/dev/zero of=/bigfile bs=10240k || true
rm -vf /bigfile

swapon --show=NAME,UUID | tail -n +2 | while read dev uuid ; do
	echo "DEV: $dev, UUID: $uuid"
	swapoff $dev
	dd if=/dev/zero of=$dev bs=10240k || true
	mkswap -U $uuid $dev
done

poweroff
