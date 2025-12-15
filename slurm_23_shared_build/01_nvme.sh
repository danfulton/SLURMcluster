#!/bin/bash

parallel-scp -t 60 -h hostfile.txt $PWD/nvme.sh ~/nvme.sh
parallel-ssh -t 180 -i -h hostfile.txt ~/nvme.sh
