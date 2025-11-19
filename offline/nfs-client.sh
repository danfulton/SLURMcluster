#!/bin/bash

mount="/share"
#plae the IP address of the headnode here
server="180.9.20.214"

#sudo apt install nfs-common -y
sudo mkdir -p $mount
grep -q "/share" /etc/fstab ||  sudo bash -c "echo \"${server}:/share /share nfs4 defaults,nofail 0 2\" >> /etc/fstab"
sudo systemctl daemon-reload
sudo mount $mount
