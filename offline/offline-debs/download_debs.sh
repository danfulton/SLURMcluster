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

apt download apparmor-utils clustershell libpam0g-dev libpmix-bin libpmix-dev libpmix2t64 parallel python3-apparmor python3-clustershell libevent-dev libevent-extra-2.1-7t64 libevent-openssl-2.1-7t64 libevent-pthreads-2.1-7t64 python3-libapparmor ncal equivs libdbus-1-dev bsdmainutils bats libhwloc-dev squashfuse libsquashfuse0 hwloc libhwloc-common

arch=$(dpkg --print-architecture)
curl -fSsL -O https://github.com/NVIDIA/enroot/releases/download/v4.0.1/enroot_4.0.1-1_${arch}.deb
curl -fSsL -O https://github.com/NVIDIA/enroot/releases/download/v4.0.1/enroot+caps_4.0.1-1_${arch}.deb # optional

mkdir -p  /share/offline-debs/server
cd /share/offline-debs/server

apt download nfs-kernel-server

mkdir -p  /share/offline-debs/pmix-build
apt download python3-sphinx recommonmark-scripts python3-recommonmark python-recommonmark-doc python3-docutils sphinx-rtd-theme-common alsa-topology-conf alsa-ucm-conf ca-certificates-java default-jre default-jre-headless docutils-common dvisvgm fonts-dejavu-extra fonts-droid-fallback  fonts-font-awesome fonts-lato fonts-lmodern fonts-noto-mono fonts-texgyre fonts-texgyre-math fonts-urw-base35 java-common libapache-pom-java libasound2-data    libasound2t64 libatk-wrapper-java libatk-wrapper-java-jni libbit-vector-perl libcarp-clan-perl libcommons-logging-java libcommons-parent-java libcrypt-rc4-perl      libdate-calc-perl libdate-calc-xs-perl libdate-manip-perl libdigest-perl-md5-perl libfile-desktopentry-perl libfile-mimeinfo-perl libfontbox-java libgif7        libgles2 libgs-common libgs10 libgs10-common libgumbo2 libidn12 libijs-0.35 libio-stringy-perl libjbig2dec0 libjcode-pm-perl libkpathsea6 libmujs3      libnet-dbus-perl libole-storage-lite-perl libpaper-utils libpaper1 libparse-recdescent-perl libpcsclite1 libpdfbox-java libpotrace0 libptexenc1 libruby          libruby3.2 libspreadsheet-parseexcel-perl libspreadsheet-writeexcel-perl libsynctex2 libteckit0 libtexlua53-5 libtie-ixhash-perl libunicode-map-perl libwoff1            libx11-protocol-perl libxml-twig-perl libxml-xpathengine-perl libxv1 libxxf86dga1 libzzip-0-13t64 lmodern mupdf-tools openjdk-21-jre openjdk-21-jre-headless             poppler-data preview-latex-style python-recommonmark-doc python3-alabaster python3-commonmark python3-docutils python3-imagesize python3-recommonmark            python3-roman python3-snowballstemmer python3-sphinx rake recommonmark-scripts ruby ruby-net-telnet ruby-rubygems ruby-sdbm ruby-webrick ruby-xmlrpc ruby3.2             rubygems-integration sphinx-common sphinx-rtd-theme-common teckit tex-gyre texlive-base texlive-binaries texlive-fonts-recommended texlive-latex-base                    texlive-latex-extra texlive-latex-recommended texlive-pictures texlive-plain-generic texlive-xetex tipa x11-utils x11-xserver-utils xdg-utils zutty  python3-all python3-sphinx-rtd-theme python3-sphinxcontrib.jquery doxygen libfmt9 libfuse3-dev libxapian30 lcov libalgorithm-c3-perl libclass-c3-perl libclass-c3-xs-perl libclass-inspector-perl libclass-singleton-perl libdatetime-locale-perl libdatetime-perl  libdatetime-timezone-perl libdevel-caller-perl libdevel-lexalias-perl libeval-closure-perl libfile-sharedir-perl libgd-perl libmro-compat-perl    libnamespace-autoclean-perl libpadwalker-perl libparams-validationcompiler-perl libreadonly-perl libref-util-perl libref-util-xs-perl libspecio-perl      libxstring-perl chrpath cython3
