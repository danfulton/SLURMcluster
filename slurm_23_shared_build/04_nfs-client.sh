#!/bin/bash

sed -i "s/^NFSSERVER=.*/NFSSERVER=$(hostname -s)/" $(dirname ${BASH_SOURCE[0]})/nfs-client.sh

parallel-scp -h hostfile.txt $PWD/nfs-client.sh ~/nfs-client.sh
parallel-ssh -i -h hostfile.txt ~/nfs-client.sh
