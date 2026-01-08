#!/bin/bash

mkdir -p /share/sources
cd /share/sources
#curl -fSsL -O https://download.schedmd.com/slurm/slurm-25.11.0.tar.bz2
curl -fSsL -O https://download.schedmd.com/slurm/slurm-23.11.5.tar.bz2
curl -fSsL -O https://github.com/NVIDIA/pyxis/archive/refs/tags/v0.20.0.tar.gz
curl -fSsL -O https://github.com/openpmix/openpmix/releases/download/v4.2.9/pmix-4.2.9.tar.gz


