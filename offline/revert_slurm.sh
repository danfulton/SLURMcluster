#!/bin/bash
#


parallel-ssh -i -p 256 -h ${1} "sudo apt -y install /share/offline-debs/slurm/*.deb   /share/offline-debs/misc/*.deb"
