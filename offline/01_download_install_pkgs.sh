#!/usr/bin/env bash

set -euo pipefail
#set -euo pipefail breaks changing to the script_dir if read after a change of directory.
script_dir=$(dirname "$(readlink -f "$0")")


module load mpi/hpcx

export SCHEDROOT=/share/sched
if [[ -e  /etc/slurm ]]; then
    if [[ ! -L /etc/slurm ]]; then
        sudo mv /etc/slurm /etc/slurm.bak
        mkdir -p  ${SCHEDROOT}/slurm/etc
        sudo ln -sT ${SCHEDROOT}/slurm/etc /etc/slurm
    fi
else
    mkdir -p ${SCHEDROOT}/slurm/etc
    sudo ln -sTf ${SCHEDROOT}/slurm/etc /etc/slurm
fi

${script_dir}/offline-debs/download_debs.sh
${script_dir}/sources/download_sources.sh

sudo apt -y install /share/offline-debs/mariadb/*.deb
sudo apt -y install /share/offline-debs/misc/*.deb
sudo apt -y install /share/offline-debs/slurm/*.deb  /share/offline-debs/slurm/server/*.deb /share/offline-debs/slurm/build-slurm/*.deb


mkdir -p /share/build
cd /share/build
tar -xf  /share/sources/v0.20.0.tar.gz
tar -xf  /share/sources/slurm-25.11.0.tar.bz2
cd slurm-25.11.0
export DEBUILD_DPKG_BUILDPACKAGE_OPTS="-j 90 --preserve-env"
ARCH=$(uname -m) 
sed -i "s|dh_auto_configure -- --sysconfdir=/etc/slurm --disable-debug --with-mysql_config --with-slurmrestd --with-pmix --enable-pam --with-pam_dir=/usr/lib/\$(DEB_HOST_MULTIARCH)/security --with-systemdsystemunitdir=/lib/systemd/system/ SUCMD=/bin/su SLEEP_CMD=/bin/sleep$|dh_auto_configure -- --sysconfdir=/etc/slurm --disable-debug --with-mysql_config --with-slurmrestd --with-pmix=/usr/lib/${ARCH}-linux-gnu/pmix2 --enable-pam --with-pam_dir=/usr/lib/\$(DEB_HOST_MULTIARCH)/security --with-systemdsystemunitdir=/lib/systemd/system/ SUCMD=/bin/su SLEEP_CMD=/bin/sleep  --disable-x11 --with-json --with-jwt --with-http-parser --with-yaml --with-hdf5=yes --with-lz4 --with-hwloc --with-nvml --with-lua --with-munge --with-libcurl |" debian/rules
sudo mk-build-deps -i debian/control
debuild -b -uc -us
mkdir -p /share/offline-debs/slurm-local-build/
cp ../slurm*.deb /share/offline-debs/slurm-local-build/
cd /share/offline-debs/slurm-local-build/
rm *sview*.deb
mkdir -p server
mv slurm-smd-slurmctld*.deb  slurm-smd-slurmdbd*.deb  slurm-smd-slurmrestd*.deb server/

sudo apt -y install /share/offline-debs/slurm-local-build/*.deb /share/offline-debs/slurm-local-build/server/*.deb

rm -rf /share/build/slurm-25.11.0

cd /share/build/pyxis-0.20.0
make orig
make deb
cp ../nvslurm-plugin-pyxis*.deb /share/offline-debs/slurm/
sudo apt -y install /share/offline-debs/slurm/nvslurm-plugin-pyxis*.deb


cd ${script_dir}
sudo mkdir -p /var/log/slurm
sudo chown -R slurm:slurm /var/log/slurm
sudo mkdir -p /var/spool/slurm
sudo chown -R slurm:slurm /var/spool/slurm
sudo mkdir -p $SCHEDROOT/slurm/etc/slurmctld_state
sudo chown -R slurm:slurm $SCHEDROOT/slurm/etc/slurmctld_state
sudo chmod -R 755 $SCHEDROOT/slurm/etc/slurmctld_state
sudo mkdir -p $SCHEDROOT/slurm/etc/plugstack.conf.d
echo 'include /share/sched/slurm/etc/plugstack.conf.d/*' | sudo tee $SCHEDROOT/slurm/etc/plugstack.conf
sudo chown slurm:slurm $SCHEDROOT/slurm/etc/plugstack.conf
echo "required /usr/lib/${ARCH}-linux-gnu/slurm/spank_pyxis.so" | sudo tee $SCHEDROOT/slurm/etc/plugstack.conf.d/pyxis.conf
sudo chown slurm:slurm $SCHEDROOT/slurm/etc/plugstack.conf.d/pyxis.conf

${script_dir}/tune-gres-conf.sh ${script_dir}/hostfile.txt
${script_dir}/tune-slurm-conf.sh ${script_dir}/hostfile.txt

sudo chown -R slurm:slurm $SCHEDROOT/slurm

