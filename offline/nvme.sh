#!/bin/bash

# Read lsblk output into arrays
declare -a names types mountpoints
while IFS= read -r line; do
    read -r name type mountpoint <<< "$line"
    names+=("$name")
    types+=("$type")
    mountpoints+=("$mountpoint")
done < <(lsblk -o NAME,TYPE,MOUNTPOINTS)

# Collect disk names that have no children (partitions or raid)
nvmes=()
for ((i=1; i<${#types[@]}; i++)); do
    if [[ "${types[i]}" == "disk" ]]; then
        # Check if the next line is a child (starts with special characters)
        has_children=false
        if [[ $((i+1)) -lt ${#types[@]} ]]; then
            next_name="${names[$((i+1))]}"
            # Check if next line starts with └, ├, or │ (indicating it's a child)
            if [[ "$next_name" =~ ^[└├│] ]]; then
                has_children=true
            fi
        fi
        
        # Only add disks without children
        if [[ "$has_children" == false ]]; then
            # Remove any leading special characters from the name
            clean_name="${names[i]}"
            clean_name="${clean_name#└─}"
            clean_name="${clean_name#├─}"
            clean_name="${clean_name#│}"
            nvmes+=("$clean_name")
        fi
    fi
done


# Echo available NVMe devices
echo "Available unused NVMe devices:"
for nvme in "${nvmes[@]}"; do
    echo "  $nvme"
done


# Use the first two devices for RAID
echo "Creating RAID with: ${nvmes[0]} ${nvmes[1]}"

# Check if RAID device already exists
if [[ -e /dev/md110 ]]; then
    echo "RAID device /dev/md110 already exists, skipping creation"
else
    sudo mdadm --create /dev/md110 --level 0 --raid-devices 2 /dev/${nvmes[0]} /dev/${nvmes[1]}
    echo "RAID device /dev/md110 created successfully"
fi

# Check if device is already mounted
if mountpoint -q /mnt/resource_nvme; then
    echo "/mnt/resource_nvme is already mounted, skipping filesystem creation and mount"
else
    # Check if filesystem exists on the RAID device
    if sudo blkid /dev/md110 | grep -q "TYPE="; then
        echo "Filesystem already exists on /dev/md110, skipping mkfs"
    else
        sudo mkfs.xfs -L resourcevnme /dev/md110
        echo "Filesystem created on /dev/md110"
    fi
    
    # Create mount point if it doesn't exist
    if [[ ! -d /mnt/resource_nvme ]]; then
        sudo mkdir -p /mnt/resource_nvme
        echo "Created mount point /mnt/resource_nvme"
    fi

    # Add to fstab if not already present
    if ! grep -q "/mnt/resource_nvme" /etc/fstab; then
        sudo echo "LABEL=resourcevnme /mnt/resource_nvme xfs defaults 0 0" | sudo tee -a /etc/fstab
        echo "Added /dev/md110 to /etc/fstab"
    else
        echo "/dev/md110 is already in /etc/fstab, skipping"
    fi
    
    # Mount the device
    sudo mount /mnt/resource_nvme
    echo "Mounted /dev/md110 to /mnt/resource_nvme"
    
    # Set permissions
    sudo chmod 1777 /mnt/resource_nvme
    echo "Set permissions on /mnt/resource_nvme"
fi
