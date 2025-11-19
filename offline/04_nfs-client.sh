#!/bin/bash

sed -i "s/^NFSSERVER=.*/NFSSERVER=$(hostname -s)/" $(dirname ${BASH_SOURCE[0]})/nfs-client.sh

parallel-scp -h clientfile.txt $PWD/nfs-client.sh ~/nfs-client.sh
parallel-ssh -i -h clientfile.txt ~/nfs-client.sh
