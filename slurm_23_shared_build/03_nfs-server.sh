#!/bin/bash

sudo apt install -y /share/offline-debs/misc/nfs-kernel-server*.deb
sudo chown nobody:nogroup /share
echo -e "[nfsd]\nthreads=144" > /tmp/nfs_threads.conf
sudo cp  /tmp/nfs_threads.conf /etc/nfs.conf.d/
sudo systemctl restart nfs-kernel-server
sudo systemctl enable nfs-server rpcbind
sudo systemctl restart nfs-server rpcbind
echo "/share    *(rw,sync,no_subtree_check,no_root_squash,insecure)" | sudo tee /etc/exports
sudo exportfs -a

