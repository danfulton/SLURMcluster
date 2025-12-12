#!/bin/bash

file=$1

parallel-scp -p 256 -t 60 -h ${file} $PWD/compute.sh ~/compute.sh
parallel-scp -p 256 -t 60 -h ${file} $PWD/fix-user-namespace.sh ~/fix-user-namespace.sh
#parallel-scp -h ${file} $PWD/apparmor.profile ~/apparmor.profile
parallel-ssh -p 256 -t 600 -i -h ${file} ~/compute.sh
parallel-ssh -p 256 -t 600 -i -h ${file} ~/fix-user-namespace.sh
