#!/bin/bash

module load mpi/hpcx

ARCH=$(uname -m)

export SCHEDROOT=/share/sched
mkdir -p $SCHEDROOT/slurm/etc
if [[ -e  /etc/slurm ]]; then
    if [[ ! -L /etc/slurm ]]; then
        sudo mv /etc/slurm /etc/slurm.bak
        mkdir -p  ${SCHEDROOT}/slurm/etc
        sudo ln -sT ${SCHEDROOT}/slurm/etc /etc/slurm
    fi
else
    ${SCHEDROOT}/slurm/etc
    sudo ln -sTf ${SCHEDROOT}/slurm/etc /etc/slurm
fi

etc_munge_key_state=$(sudo md5sum /etc/munge/munge.key |  awk '{print $1}' )
slurm_munge_key_state=$(sudo md5sum $SCHEDROOT/slurm/etc/munge.key | awk '{print $1}')
# Do not change munge key after first time unless they are different already.
if [[ $etc_munge_key_state != $slurm_munge_key_state ]]; then
sudo systemctl start munge
sudo systemctl status munge --no-pager
sudo mungekey --create --force
sudo chown munge:munge /etc/munge/munge.key
sudo systemctl enable munge
sudo systemctl restart munge
sudo cp /etc/munge/munge.key $SCHEDROOT/slurm/etc
fi

sudo mkdir -p /var/log/slurm
sudo chown slurm:slurm /var/log/slurm
sudo mkdir -p /var/spool/slurm
sudo chown slurm:slurm /var/spool/slurm
sudo mkdir -p $SCHEDROOT/slurm/etc/nodegroups.d
sudo chown slurm:slurm $SCHEDROOT/slurm/etc/nodegroups.d
sudo mkdir -p $SCHEDROOT/slurm/etc/slurmctld_state
sudo chown slurm:slurm $SCHEDROOT/slurm/etc/slurmctld_state
sudo chmod -R 755 $SCHEDROOT/slurm/etc/slurmctld_state 
sudo mkdir -p /var/spool/slurmd
sudo chown slurm:slurm /var/spool/slurmd


# setup slurmdbd conf here too

sed -i -E "s/^SlurmctldHost.*/SlurmctldHost=$(hostname)/" slurm.conf
sed -i "s:^AccountingStorageUser=slurm.*$:#AccountingStorageUser=slurm:" slurm.conf
sed -i "s:PidFile=/var/run/slurm/slurmdbd.pid:PidFile=/var/run/slurmdbd/slurmdbd.pid:" slurmdbd.conf
echo 'SLURMCTLD_OPTIONS=" -i -c"' | sudo tee /etc/default/slurmctld
sudo cp slurm.conf cgroup.conf gres.conf slurmdbd.conf topology.txt $SCHEDROOT/slurm/etc/
sudo cp nodegroups.d/*.conf $SCHEDROOT/slurm/etc/nodegroups.d/
sudo chown slurm:slurm $SCHEDROOT/slurm/etc/*.conf  $SCHEDROOT/slurm/etc/nodegroups.d/*.conf

sudo mkdir /var/spool/slurmctld
sudo chown slurm:slurm /var/spool/slurmctld
sudo cp -fv /usr/share/enroot/hooks.d/50-slurm-pmi.sh /usr/share/enroot/hooks.d/50-slurm-pytorch.sh /etc/enroot/hooks.d

sudo systemctl enable slurmdbd 
sudo systemctl enable slurmctld
sudo systemctl start slurmdbd
sudo systemctl start slurmctld 
sudo systemctl status slurmctld --no-pager
sleep 8

echo 'SLURMCTLD_OPTIONS="-i"' | sudo tee  /etc/default/slurmctld

sudo mkdir -p $SCHEDROOT/slurm/etc/plugstack.conf.d
echo 'include /share/sched/slurm/etc/plugstack.conf.d/*' | sudo tee $SCHEDROOT/slurm/etc/plugstack.conf
sudo chown slurm:slurm $SCHEDROOT/slurm/etc/plugstack.conf
echo "required /usr/lib/${ARCH}-linux-gnu/slurm/spank_pyxis.so" | sudo tee $SCHEDROOT/slurm/etc/plugstack.conf.d/pyxis.conf
sudo chown slurm:slurm $SCHEDROOT/slurm/etc/plugstack.conf.d/pyxis.conf

sudo cp prolog.sh $SCHEDROOT/slurm/etc
sudo chown slurm:slurm $SCHEDROOT/slurm/etc/prolog.sh
sudo chmod 755 $SCHEDROOT/slurm/etc/prolog.sh
sudo cp $PWD/apparmor.profile /share/apparmor.profile

sleep 5
sudo sacctmgr -i add account debug cluster=NDv6 && sudo sacctmgr -i add user azhpcuser account=debug
sudo sacctmgr -i add account AICE Description="AICE Testing" Organization="AICE"
sudo sacctmgr -i add user azhpcuser account=AICE

sudo cp /share/apparmor.profile /etc/apparmor.d/enroot
sudo aa-complain /usr/bin/enroot-nsenter
sudo aa-complain /etc/apparmor.d/*
sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0
echo 'kernel.apparmor_restrict_unprivileged_userns=0' | sudo tee -a /etc/sysctl.d/99-enroot.conf
sudo apparmor_parser -R /etc/apparmor.d/enroot

#sudo systemctl enable slurmd
#sudo systemctl start slurmd
sudo scontrol reconfigure
#sudo scontrol update nodename=$(hostname -s) state=drain reason="AICE:slurmctld node"
#./fix-user-namespace.sh


