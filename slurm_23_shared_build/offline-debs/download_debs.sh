#!/bin/bash
#


mkdir -p /share/offline-debs

cd /share/offline-debs



mkdir -p /share/offline-debs/mariadb

cd /share/offline-debs/mariadb

apt download galera-4 libconfig-inifiles-perl libdbd-mysql-perl libdbi-perl libhtml-template-perl libmariadb-dev libmariadb3 libmariadbd-dev libmariadbd19t64 libmysqlclient21 libodbcinst2 liburing2 mariadb-client mariadb-client-core mariadb-common mariadb-plugin-provider-bzip2 mariadb-plugin-provider-lz4 mariadb-plugin-provider-lzma mariadb-plugin-provider-lzo mariadb-plugin-provider-snappy mariadb-server mariadb-server-core mysql-common odbc-mariadb odbcinst pv socat unixodbc-common


mkdir -p  /share/offline-debs/misc
cd /share/offline-debs/misc

apt download apparmor-utils clustershell libpam0g-dev libpmix-bin libpmix-dev parallel python3-apparmor python3-clustershell libevent-dev libevent-extra-2.1-7t64 libevent-openssl-2.1-7t64 libevent-pthreads-2.1-7t64 python3-libapparmor ncal equivs libdbus-1-dev bsdmainutils bats libhwloc-dev hwloc libhwloc-common  nfs-kernel-server libmunge-dev libmunge2 munge

arch=$(dpkg --print-architecture)
curl -fSsL -O https://github.com/NVIDIA/enroot/releases/download/v4.0.1/enroot_4.0.1-1_${arch}.deb
curl -fSsL -O https://github.com/NVIDIA/enroot/releases/download/v4.0.1/enroot+caps_4.0.1-1_${arch}.deb # optional


