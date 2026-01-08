#!/usr/bin/env bash

set -euo pipefail
#set -euo pipefail breaks changing to the script_dir if read after a change of directory.
script_dir=$(dirname "$(readlink -f "$0")")

getent group slurm >/dev/null || sudo addgroup --system --gid 64030 slurm
id -u slurm >/dev/null 2>&1 || sudo adduser  --system --uid 64030  --gid 64030  --disabled-login --disabled-password --no-create-home --gecos "" --shell /usr/sbin/nologin slurm

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


mkdir -p /share/build
cd /share/build
tar -xf  /share/sources/v0.20.0.tar.gz
tar -xf  /share/sources/slurm-23.11.5.tar.bz2
tar -xf  /share/sources/pmix-4.2.9.tar.gz

cd pmix-4.2.9
#./configure --prefix=$SCHEDROOT/pmix/v4 --with-ucx=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ucx --with-hwloc --with-zlib --with-curl 
./configure --prefix=$SCHEDROOT/pmix/v4  
sudo make -j install
cd ..

cp /share/sources/slurm-23.11.5.tar.bz2 .
tar xjf slurm-23.11.5.tar.bz2
cd slurm-23.11.5/
# CHange back to bare min ## ./configure --prefix=$SCHEDROOT/slurm/23.11.5 --sysconfdir=$SCHEDROOT/slurm/etc --with-pmix=$SCHEDROOT/pmix/v4 --with-hwloc --enable-pam --disable-x11 --with-mysql_config --with-hwloc --enable-pam --disable-x11  --with-json --with-yaml --with-nvml  --with-lua --with-munge --with-libcurl --with-ucx=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ucx
./configure --prefix=$SCHEDROOT/slurm/23.11.5 --sysconfdir=$SCHEDROOT/slurm/etc --with-pmix=$SCHEDROOT/pmix/v4 --with-hwloc --enable-pam --disable-x11 --with-mysql_config 
make -j 90
sudo make install
sudo cp etc/slurmctld.service /etc/systemd/system/
sudo cp etc/slurmdbd.service /etc/systemd/system/
sudo cp etc/slurmd.service  $SCHEDROOT/slurm/etc/slurmd.service
cd ..

tar xzf  /share/sources/v0.20.0.tar.gz
cd pyxis-0.20.0
sudo CFLAGS='-I/share/sched/slurm/23.11.5/include' prefix=$SCHEDROOT/slurm/23.11.5 make install
cd ..


#cd slurm-25.11.0
#export DEBUILD_DPKG_BUILDPACKAGE_OPTS="-j 90 --preserve-env"
#ARCH=$(uname -m) 
#sed -i "s|dh_auto_configure -- --sysconfdir=/etc/slurm --disable-debug --with-mysql_config --with-slurmrestd --with-pmix --enable-pam --with-pam_dir=/usr/lib/\$(DEB_HOST_MULTIARCH)/security --with-systemdsystemunitdir=/lib/systemd/system/ SUCMD=/bin/su SLEEP_CMD=/bin/sleep$|dh_auto_configure -- --sysconfdir=/etc/slurm --disable-debug --with-mysql_config --with-slurmrestd --with-pmix=$SCHEDROOT/pmix/v4 --enable-pam --with-pam_dir=/usr/lib/\$(DEB_HOST_MULTIARCH)/security --with-systemdsystemunitdir=/lib/systemd/system/ SUCMD=/bin/su SLEEP_CMD=/bin/sleep  --disable-x11 --with-json --with-jwt --with-http-parser --with-yaml --with-hdf5=yes --with-lz4 --with-hwloc --with-nvml --with-lua --with-munge --with-libcurl --with-ucx=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ucx|" debian/rules
#sudo mk-build-deps -i debian/control
#debuild -b -uc -us
#mkdir -p /share/offline-debs/slurm-local-build/
#cp ../slurm*.deb /share/offline-debs/slurm-local-build/
#cd /share/offline-debs/slurm-local-build/
#rm *sview*.deb
#mkdir -p server
#mv slurm-smd-slurmctld*.deb  slurm-smd-slurmdbd*.deb  slurm-smd-slurmrestd*.deb server/

#sudo apt -y install /share/offline-debs/slurm-local-build/*.deb /share/offline-debs/slurm-local-build/server/*.deb

#rm -rf /share/build/slurm-25.11.0

#cd /share/build/pyxis-0.20.0
#make orig
#make deb
#cp ../nvslurm-plugin-pyxis*.deb /share/offline-debs/slurm/
#sudo apt -y install /share/offline-debs/slurm/nvslurm-plugin-pyxis*.deb


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
#echo "required /usr/lib/${ARCH}-linux-gnu/slurm/spank_pyxis.so" | sudo tee $SCHEDROOT/slurm/etc/plugstack.conf.d/pyxis.conf
echo "required /share/sched/slurm/23.11.5/lib/slurm/spank_pyxis.so" | sudo tee $SCHEDROOT/slurm/etc/plugstack.conf.d/pyxis.conf
sudo chown slurm:slurm $SCHEDROOT/slurm/etc/plugstack.conf.d/pyxis.conf

${script_dir}/tune-gres-conf.sh ${script_dir}/hostfile.txt
${script_dir}/tune-slurm-conf.sh ${script_dir}/hostfile.txt

sudo chown -R slurm:slurm $SCHEDROOT/slurm

