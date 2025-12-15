#!/usr/bin/env bash

set -euo pipefail
#set -euo pipefail breaks changing to the script_dir if read after a change of directory.
script_dir=$(dirname "$(readlink -f "$0")")

getent group slurm >/dev/null || sudo addgroup --system --gid 64030 slurm
id -u slurm >/dev/null 2>&1 || sudo adduser  --system --uid 64030  --gid 64030  --disabled-login --disabled-password --no-create-home --gecos "" --shell /usr/sbin/nologin slurm

module load mpi/hpcx
export HPCX_HCOLL_DIR=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/hcoll
export PKG_CONFIG_PATH=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ompi/lib/pkgconfig:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ucx/lib/pkgconfig:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/sharp/lib/pkgconfig:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/hcoll/lib/pkgconfig::/opt/mellanox/flexio/lib/pkgconfig:/opt/mellanox/dpdk/lib/aarch64-linux-gnu/pkgconfig
export HPCX_CLUSTERKIT_DIR=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/clusterkit
export OMPI_HOME=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ompi
export HPCX_OSU_CUDA_DIR=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ompi/tests/osu-micro-benchmarks-cuda
export HPCX_OSU_DIR=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ompi/tests/osu-micro-benchmarks
export HPCX_MPI_DIR=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ompi
export HPCX_OSHMEM_DIR=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ompi
export HPCX_UCC_DIR=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ucc
export MANPATH=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ompi/share/man
export HPCX_HOME=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64
export MPI_HOME=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ompi
export OSHMEM_HOME=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ompi
export HPCX_UCX_DIR=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ucx
export SHMEM_HOME=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ompi
export LIBRARY_PATH=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/nccl_rdma_sharp_plugin/lib:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ncclnet_plugin/lib:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ompi/lib:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/sharp/lib:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/hcoll/lib:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ucc/lib:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ucx/lib
export HPCX_SHARP_DIR=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/sharp
export LOADEDMODULES=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/modulefiles/hpcx:mpi/hpcx
export HPCX_NCCLNET_PLUGIN_DIR=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ncclnet_plugin
export PMIX_INSTALL_PREFIX=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ompi
export HPCX_DIR=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64
export LD_LIBRARY_PATH=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/nccl_rdma_sharp_plugin/lib:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ncclnet_plugin/lib:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ompi/lib:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/sharp/lib:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/hcoll/lib:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ucc/lib/ucc:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ucc/lib:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ucx/lib/ucx:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ucx/lib:/usr/local/cuda/lib64:
export OPAL_PREFIX=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ompi
export PATH=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ompi/bin:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/clusterkit/bin:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ompi/tests/imb:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/sharp/bin:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/hcoll/bin:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ucc/bin:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ucx/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/opt/mellanox/doca/tools/
export HPCX_NCCL_RDMA_SHARP_PLUGIN_DIR=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/nccl_rdma_sharp_plugin
export HPCX_MPI_TESTS_DIR=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ompi/tests
export CPATH=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ompi/include:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ucc/include:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ucx/include:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/sharp/include:/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/hcoll/include


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
#sudo apt -y install /share/offline-debs/slurm/*.deb  /share/offline-debs/slurm/server/*.deb /share/offline-debs/slurm/build-slurm/*.deb
sudo apt -y install /share/offline-debs/slurm/build-slurm/*.deb


mkdir -p /share/build
cd /share/build
tar -xf  /share/sources/v0.20.0.tar.gz
tar -xf  /share/sources/slurm-25.11.0.tar.bz2
tar -xf  /share/sources/pmix-4.2.9.tar.gz

cd pmix-4.2.9
./configure --prefix=$SCHEDROOT/pmix/v4 --with-ucx=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ucx --with-hwloc --with-zlib --with-curl 
sudo make -j install
cd ..

cp /share/sources/slurm-23.11.5.tar.bz2 .
tar xjf slurm-23.11.5.tar.bz2
cd slurm-23.11.5/
./configure --prefix=$SCHEDROOT/slurm/23.11.5 --sysconfdir=$SCHEDROOT/slurm/etc --with-pmix=$SCHEDROOT/pmix/v4 --with-hwloc --enable-pam --disable-x11 --with-mysql_config --with-hwloc --enable-pam --disable-x11  --with-json --with-yaml --with-nvml  --with-lua --with-munge --with-libcurl --with-ucx=/opt/hpcx-v2.24.1-gcc-doca_ofed-ubuntu24.04-cuda13-aarch64/ucx --with bash-completion
make -j 90
sudo make install
sudo cp etc/slurmctld.service /etc/systemd/system/
sudo cp etc/slurmdbd.service /etc/systemd/system/
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

