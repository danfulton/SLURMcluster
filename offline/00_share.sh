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
echo "Creating RAID with: ${nvmes[0]} ${nvmes[1]} ${nvmes[2]}"

if [[ -e /dev/${nvmes[0]} && -e /dev/${nvmes[1]} && -e /dev/${nvmes[2]} ]]; then
    # Check if RAID device already exists
    if [[ -e /dev/md120 ]]; then
        echo "RAID device /dev/md120 already exists, skipping creation"
    else
        sudo mdadm --create /dev/md120 --level 0 --raid-devices 3 /dev/${nvmes[0]} /dev/${nvmes[1]} /dev/${nvmes[2]}
        echo "RAID device /dev/md120 created successfully"
    fi
else
    echo "Not enough devices left."
fi
# Check if device is already mounted
if mountpoint -q /share; then
    echo "/share is already mounted, skipping filesystem creation and mount"
else
    # Check if filesystem exists on the RAID device
    if sudo blkid /dev/md120 | grep -q "TYPE="; then
        echo "Filesystem already exists on /dev/md120, skipping mkfs"
    else
        sudo mkfs.xfs -L share /dev/md120
        echo "Filesystem created on /dev/md120"
    fi
    
    # Create mount point if it doesn't exist
    if [[ ! -d /share ]]; then
        sudo mkdir -p /share
        echo "Created mount point /share"
    fi

    # Add to fstab if not already present
    if ! grep -q "/share" /etc/fstab; then
        sudo echo "LABEL=share /share xfs defaults 0 0" | sudo tee -a /etc/fstab
        echo "Added /dev/md120 to /etc/fstab"
    else
        echo "/dev/md120 is already in /etc/fstab, skipping"
    fi
    
    # Mount the device
    sudo mount /share
    echo "Mounted /dev/md120 to /share"
    
    # Set permissions
    sudo chmod 1777 /share
    echo "Set permissions on /share"
fi


