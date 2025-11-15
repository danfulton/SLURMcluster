#!/bin/bash

nvmes=($(lsblk -o NAME,TYPE,MOUNTPOINTS | awk '
{
    lines[NR]=$0
    types[NR]=$2
}
END {
    to_remove=""
    for (i=2; i<=NR; i++) {
        # If this line is a partition ("part"), mark it and the previous line to remove
        if (types[i] == "part") {
            to_remove = to_remove i " " (i-1) " "
        }
    }
    # Print lines that are "disk" and were NOT marked for removal
    split(to_remove, rm, " ")
    for (i=1; i<=NR; i++) {
        remove=0
        for (j in rm) { if (i == rm[j]) remove=1 }
        if (!remove && types[i] == "disk") {
            # Print just the disk name (first column), not the whole line
            split(lines[i], cols, " ")
            print cols[1]
        }
    }
}
'))

# Leave the first disk untouched
echo "Disk left untouched: ${nvmes[0]}"

# Pair the rest for RAID
echo "RAID pair 1: ${nvmes[1]} ${nvmes[2]}"
echo "RAID pair 2: ${nvmes[3]} ${nvmes[4]}"


grep -c md110 /proc/mdstat || sudo mdadm --create /dev/md110 --level 0 --raid-devices 2 /dev/${nvmes[1]} /dev/${nvmes[2]}
grep -c resource_nvme /proc/mounts && sudo umount /mnt/resource_nvme
sudo mkfs.xfs -f -L resourcenvme /dev/md110
sudo mkdir -p /mnt/resource_nvme
sudo chmod 1777 /mnt/resource_nvme
grep -c resource_nvme /etc/fstab ||  sudo bash -c 'echo "LABEL=resourcenvme /mnt/resource_nvme xfs defaults,nofail 0 2" >> /etc/fstab'
sudo systemctl daemon-reload
sudo mount /dev/md110 /mnt/resource_nvme
