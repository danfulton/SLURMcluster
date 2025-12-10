#!/bin/bash

file=$1

parallel-scp -t 60 -h ${file} $PWD/compute.sh ~/compute.sh
parallel-scp -t 60 -h ${file} $PWD/fix-user-namespace.sh ~/fix-user-namespace.sh
#parallel-scp -h ${file} $PWD/apparmor.profile ~/apparmor.profile
parallel-ssh -t 600 -i -h ${file} ~/compute.sh
parallel-ssh -t 600 -i -h ${file} ~/fix-user-namespace.sh
