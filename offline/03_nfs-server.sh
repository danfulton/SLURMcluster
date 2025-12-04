#!/bin/bash

sudo apt install -y /share/offline-debs/server/nfs-kernel-server*.deb
sudo chown nobody:nogroup /share
sudo systemctl restart nfs-kernel-server
sudo systemctl enable nfs-server rpcbind
sudo systemctl restart nfs-server rpcbind
echo "/share    *(rw,sync,no_subtree_check,no_root_squash,insecure)" | sudo tee /etc/exports
sudo exportfs -a

