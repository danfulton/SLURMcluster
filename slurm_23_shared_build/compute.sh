#!/bin/bash

slurmctld_host=$(grep ^SlurmctldHost /share/sched/slurm/etc/slurm.conf  | awk -F= '{print $2}')

if [[ $(hostname -s) == ${slurmctld_host} ]]; then
    echo "On slurmctld host: exiting"
    exit 0
fi

export SCHEDROOT=/share/sched
if [[ -e  /etc/slurm ]]; then
    if [[ ! -L /etc/slurm ]]; then 
	sudo mv /etc/slurm /etc/slurm.bak
	sudo ln -sT ${SCHEDROOT}/slurm/etc /etc/slurm
    fi
else
    sudo ln -sTf ${SCHEDROOT}/slurm/etc /etc/slurm
fi

#slurm_version=$(ls /share/offline-debs/slurm-local-build/ | grep slurm |awk -F_ '{print $2}' | sort -u)
#slurm_installed_version=$(dpkg -l slurm-smd\* | grep slurm | awk '{print $3}' | sort -u)

#if [[ $slurm_version != $slurm_installed_version ]]; then
#sudo apt -y install /share/offline-debs/slurm/*.deb   /share/offline-debs/misc/*.deb
sudo apt -y install /share/offline-debs/misc/*.deb
#sudo apt -y install /share/offline-debs/slurm-local-build/*.deb 
#fi

sudo systemctl stop munge || true
#sudo groupmod -g 1111 munge
#sudo usermod -u 1111 -g 1111 munge
#sudo chown -R munge:munge /var/log/munge
#sudo chown -R munge:munge /etc/munge
#sudo chown -R munge:munge /var/lib/munge
sudo systemctl start munge
sudo systemctl status munge --no-pager
sudo chown -R munge:munge /var/run/munge
sudo cp $SCHEDROOT/slurm/etc/munge.key /etc/munge/munge.key
sudo chown munge:munge /etc/munge/munge.key
sudo chmod 400 /etc/munge/munge.key
sudo systemctl enable munge
sudo systemctl restart munge
sudo systemctl enable docker
sudo systemctl restart docker

getent group slurm >/dev/null || sudo addgroup --system --gid 64030 slurm
id -u slurm >/dev/null 2>&1 || sudo adduser  --system --uid 64030  --gid 64030  --disabled-login --disabled-password --no-create-home --gecos "" --shell /usr/sbin/nologin slurm

sudo mkdir -p /var/log/slurm
sudo chown slurm:slurm /var/log/slurm
sudo mkdir -p /var/spool/slurm
sudo chown -R slurm:slurm /var/spool/slurm

sudo mkdir -p /var/spool/slurmd
sudo chown slurm:slurm /var/spool/slurmd

sudo mkdir -p /var/run/slurm
sudo chown -R slurm:slurm /var/run/slurm

sudo chown -R slurm:slurm /var/log/slurm
sudo chown -R slurm:slurm /var/log/slurmd
sudo chmod -R 755 /var/log/slurm
sudo chmod 755 /var/log/slurm/*

#sudo unlink /etc/profile.d/99_slurm_path.sh
#sudo unlink /etc/profile.d/99_slurm_path.sh
#sudo ln -sf $SCHEDROOT/slurm/etc/slurm_path.sh /etc/profile.d/99_slurm_path.sh


#sudo cp $SCHEDROOT/slurm/etc/slurmd.service /usr/lib/systemd/system
sudo cp $SCHEDROOT/slurm/etc/slurmd.service /etc/systemd/system/

#echo 'export PATH=/share/sched/slurm/23.11.5/bin:/share/sched/slurm/23.11.5/sbin:$PATH' | sudo tee /share/sched/slurm/etc/slurm_path.sh
if [[ ! -e  /etc/profile.d/99_slurm_path.sh ]]; then
sudo ln -sf /share/sched/slurm/etc/slurm_path.sh /etc/profile.d/99_slurm_path.sh
fi

sudo systemctl daemon-reload
sudo systemctl enable slurmd
sudo systemctl restart slurmd
sudo cp -fv /usr/share/enroot/hooks.d/50-slurm-pmi.sh /usr/share/enroot/hooks.d/50-slurm-pytorch.sh /etc/enroot/hooks.d
sudo sed -i '/set -eu/a export PATH=/share/sched/slurm/23.11.5/bin:$PATH' /etc/enroot/hooks.d/50-slurm-pytorch.sh
sudo sed -i '/shopt -s lastpipe/a export PATH=/share/sched/slurm/23.11.5/bin:$PATH' /etc/enroot/hooks.d/50-slurm-pmi.sh

sudo cp /share/apparmor.profile /etc/apparmor.d/enroot
sudo aa-complain /usr/bin/enroot-nsenter
sudo aa-complain /etc/apparmor.d/*
sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0
echo 'kernel.apparmor_restrict_unprivileged_userns=0' | sudo tee -a /etc/sysctl.d/99-enroot.conf
sudo apparmor_parser -R /etc/apparmor.d/enroot

sudo mv /etc/enroot/hooks.d/98-nvidia.sh /etc/enroot/hooks.d/98-nvidia.sh.disabled
#
sudo modprobe nvidia_peermem
if [[ ! -e /etc/modules-load.d/nvidia_peermem.conf ]]; then
echo 'nvidia_peermem' | sudo tee /etc/modules-load.d/nvidia_peermem.conf
fi


#  m=$(grep nvidia-caps-imex-channels /proc/devices | awk '"'"'{print $1}'"'"') && sudo mknod /dev/nvidia-caps-imex-channels/channel0 c "$m" 0
if [ ! -c /dev/nvidia-caps-imex-channels/channel0 ]; then
        echo "IMEX device not created!."
        Major_Device_num=$(grep nvidia-caps-imex-channels /proc/devices | awk '{print $1}')
        sudo mknod /dev/nvidia-caps-imex-channels/channel0 c "${Major_Device_num}" 0
        sudo chmod ugo+rw /dev/nvidia-caps-imex-channels/channel0
        sudo chown azhpcuser:azhpcuser /dev/nvidia-caps-imex-channels/channel0
        if [ ! -c /dev/nvidia-caps-imex-channels/channel0 ]; then
                echo "ERROR: NVIDIA-IMEX not configured correctly"
                exit 1
        fi
fi

docker_active=$(systemctl is-active docker.service)
if [[ ${docker_active} != "active" ]]
   then
	sudo systemctl enable docker
        sudo systemctl restart docker
fi
