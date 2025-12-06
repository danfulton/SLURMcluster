#!/bin/bash
#


mkdir -p /share/offline-debs

cd /share/offline-debs

#apt download apparmor-utils bsdmainutils clustershell fonts-liberation fonts-liberation-sans-narrow fonts-liberation2 galera-4 graphviz lbt libaec0 libann0 libb64-0d libcdt5 libcgraph6 libconfig-inifiles-perl libdbd-mysql-perl libdbi-perl libdbi1t64 libevent-dev libevent-extra-2.1-7t64 libevent-openssl-2.1-7t64 libevent-pthreads-2.1-7t64 libgts-0.7-5t64 libgts-bin libgvc6 libgvpr2 libhdf5-103-1t64 libhdf5-hl-100t64 libhtml-template-perl libhwloc-dev libhwloc-plugins libhwloc15 libipmimonitoring6 libjwt2 liblab-gamut1 liblua5.1-0 libmariadb3 libmunge-dev libmunge2 libmysqlclient21 liboam-dev liboam1 libpam0g-dev libpathplan4 libpmix-bin libpmix-dev libpmix2t64 librocm-smi-dev librocm-smi64-1 librrd8t64 libsz2 liburing2 mariadb-client mariadb-client-core mariadb-common mariadb-plugin-provider-bzip2 mariadb-plugin-provider-lz4 mariadb-plugin-provider-lzma mariadb-plugin-provider-lzo mariadb-plugin-provider-snappy mariadb-server mariadb-server-core munge mysql-common ncal nfs-kernel-server ocl-icd-libopencl1 parallel pv python3-apparmor python3-clustershell python3-libapparmor slurm slurm-client slurm-wlm-basic-plugins slurm-wlm-basic-plugins-dev slurm-wlm-elasticsearch-plugin slurm-wlm-elasticsearch-plugin-dev slurm-wlm-hdf5-plugin slurm-wlm-hdf5-plugin-dev slurm-wlm-influxdb-plugin slurm-wlm-influxdb-plugin-dev slurm-wlm-ipmi-plugins slurm-wlm-ipmi-plugins-dev slurm-wlm-jwt-plugin slurm-wlm-jwt-plugin-dev slurm-wlm-mysql-plugin slurm-wlm-mysql-plugin-dev slurm-wlm-plugins slurm-wlm-plugins-dev slurm-wlm-rrd-plugin slurm-wlm-rrd-plugin-dev slurm-wlm-rsmi-plugin slurm-wlm-rsmi-plugin-dev slurmctld slurmd slurmdbd socat libmariadbd-dev libmariadbd-dev libmariadbd-dev odbc-mariadb libmariadbd19t64 


mkdir -p /share/offline-debs/mariadb

cd /share/offline-debs/mariadb

apt download galera-4 libconfig-inifiles-perl libdbd-mysql-perl libdbi-perl libhtml-template-perl libmariadb-dev libmariadb3 libmariadbd-dev libmariadbd19t64 libmysqlclient21 libodbcinst2 liburing2 mariadb-client mariadb-client-core mariadb-common mariadb-plugin-provider-bzip2 mariadb-plugin-provider-lz4 mariadb-plugin-provider-lzma mariadb-plugin-provider-lzo mariadb-plugin-provider-snappy mariadb-server mariadb-server-core mysql-common odbc-mariadb odbcinst pv socat unixodbc-common

mkdir -p /share/offline-debs/slurm

cd /share/offline-debs/slurm

apt download   libaec0 libb64-0d libdbi1t64 libhdf5-103-1t64 libhdf5-hl-100t64 libhwloc-plugins libhwloc15 libipmimonitoring6 libjwt2 liblua5.1-0 libmunge2 liboam-dev liboam1 librocm-smi-dev librocm-smi64-1 librrd8t64 libsz2 munge  ocl-icd-libopencl1 slurm-client slurm-wlm-basic-plugins slurm-wlm-basic-plugins-dev slurm-wlm-elasticsearch-plugin slurm-wlm-elasticsearch-plugin-dev slurm-wlm-hdf5-plugin slurm-wlm-hdf5-plugin-dev slurm-wlm-influxdb-plugin  slurm-wlm-influxdb-plugin-dev slurm-wlm-ipmi-plugins slurm-wlm-ipmi-plugins-dev slurm-wlm-jwt-plugin slurm-wlm-jwt-plugin-dev slurm-wlm-mysql-plugin slurm-wlm-mysql-plugin-dev slurm-wlm-plugins slurm-wlm-plugins-dev  slurm-wlm-rrd-plugin slurm-wlm-rrd-plugin-dev slurm-wlm-rsmi-plugin slurm-wlm-rsmi-plugin-dev slurmd libmunge-dev libmunge2 libslurm-dev libslurm40t64 libmysqlclient21

mkdir -p /share/offline-debs/slurm/server
cd /share/offline-debs/slurm/server
apt download slurmctld slurmdbd

mkdir -p /share/offline-debs/slurm/build-slurm
cd /share/offline-debs/slurm/build-slurm
apt download dh-exec gir1.2-atk-1.0 gir1.2-freedesktop gir1.2-freedesktop-dev gir1.2-gdkpixbuf-2.0 gir1.2-glib-2.0-dev gir1.2-gtk-2.0 gir1.2-harfbuzz-0.0  gir1.2-pango-1.0 hdf5-helpers libaec-dev libatk1.0-dev libbrotli-dev libbz2-dev libcairo-script-interpreter2 libcairo2-dev libcurl4-openssl-dev  libdatrie-dev libdeflate-dev libffi-dev libfontconfig-dev libfreeipmi-dev libfreetype-dev libfribidi-dev libgdk-pixbuf-2.0-dev libgirepository-2.0-0  libglib2.0-dev libglib2.0-dev-bin libgraphite2-dev libgtk2.0-dev libharfbuzz-cairo0 libharfbuzz-dev libharfbuzz-gobject0 libharfbuzz-icu0  libharfbuzz-subset0 libhdf5-cpp-103-1t64 libhdf5-dev libhdf5-fortran-102t64 libhdf5-hl-cpp-100t64 libhdf5-hl-fortran-100t64 libhttp-parser-dev  libhttp-parser2.9 libice-dev libipmimonitoring-dev libjbig-dev libjpeg-dev libjpeg-turbo8-dev libjpeg8-dev libjwt-dev liblerc-dev liblua5.3-dev  liblz4-dev liblzma-dev libpango1.0-dev libpangoxft-1.0-0 libperl-dev libpixman-1-dev libpng-dev libpthread-stubs0-dev librdkafka++1 librdkafka-dev  librdkafka1 librrd-dev libsharpyuv-dev libsm-dev libthai-dev libtiff-dev libtiffxx6 libwebp-dev libwebpdecoder3 libwebpdemux2 libwebpmux3 libx11-dev  libxau-dev libxcb-render0-dev libxcb-shm0-dev libxcb1-dev libxcomposite-dev libxcursor-dev libxdamage-dev libxdmcp-dev libxext-dev libxfixes-dev  libxft-dev libxi-dev libxinerama-dev libxml2-utils libxrandr-dev libxrender-dev man2html-base pango1.0-tools x11proto-core-dev x11proto-dev xorg-sgml-doctools xtrans-dev libtool-bin

mkdir -p  /share/offline-debs/misc
cd /share/offline-debs/misc

apt download apparmor-utils clustershell libpam0g-dev libpmix-bin libpmix-dev libpmix2t64 parallel python3-apparmor python3-clustershell libevent-dev libevent-extra-2.1-7t64 libevent-openssl-2.1-7t64 libevent-pthreads-2.1-7t64 python3-libapparmor ncal equivs libdbus-1-dev bsdmainutils bats libhwloc-dev

arch=$(dpkg --print-architecture)
curl -fSsL -O https://github.com/NVIDIA/enroot/releases/download/v4.0.1/enroot_4.0.1-1_${arch}.deb
curl -fSsL -O https://github.com/NVIDIA/enroot/releases/download/v4.0.1/enroot+caps_4.0.1-1_${arch}.deb # optional

mkdir -p  /share/offline-debs/server
cd /share/offline-debs/server

apt download nfs-kernel-server


