#!/bin/bash
#


parallel-ssh -i -p 256 -h ${1} "sudo apt -y purge \*slurm\*"
parallel-ssh -i -p 256 -h ${1} "sudo rm -f /var/spool/slurm/slurmd/*"
