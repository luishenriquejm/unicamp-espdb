#!/bin/bash

v_DISK="${1:-nvme1n1}"

echo $v_DISK

# format
mkfs -t xfs /dev/${v_DISK}

# create mount dir
mkdir /postgres

# capture disk uuid
v_DISK_UUID=$(blkid -s UUID -o value /dev/${v_DISK})

# backup fstab
cp /etc/fstab /etc/fstab.orig

# add config to fstab
echo "UUID=${v_DISK_UUID} /postgres xfs defaults,nofail 0 2" >> /etc/fstab
systemctl daemon-reload

# mount
mount -a
