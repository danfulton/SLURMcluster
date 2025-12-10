#!/bin/bash

input_file="$1"

if [[ -e gres.conf ]]; then
        rm gres.conf
fi
for i in $(cat ${input_file}); do
	echo "Nodename=$i Name=gpu Count=4 File=/dev/nvidia[0-3]" >> gres.conf
done
