#!/bin/bash

sed -i "s/^NFSSERVER=.*/NFSSERVER=$(hostname -s)/" $(dirname ${BASH_SOURCE[0]})/nfs-client.sh

parallel-scp -t 10 -p 256 -h  hostfile.txt /etc/hosts /tmp/
parallel-ssh -i -t 10 -p 256 -h  hostfile.txt "sudo cp /tmp/hosts /etc/hosts"
parallel-scp -t 10 -p 256 -h hostfile.txt $PWD/nfs-client.sh ~/nfs-client.sh
parallel-ssh -i  -t 10 -p 256 -h hostfile.txt ~/nfs-client.sh
