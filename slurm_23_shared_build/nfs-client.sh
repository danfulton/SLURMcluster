#!/bin/bash

mount="/share"
#place the IP address of the headnode here
NFSSERVER=ATL210111780121

if [ -z "$NFSSERVER" ]; then
	echo "NFS server address is not set!"
	exit 1
fi

#sudo apt install nfs-common -y
sudo mkdir -p $mount
grep -q "/share" /etc/fstab ||  sudo bash -c "echo \"${NFSSERVER}:/share /share nfs defaults,nofail,vers=3 0 2\" >> /etc/fstab"
sudo systemctl daemon-reload
grep -q "/share" /proc/mounts || sudo mount $mount
