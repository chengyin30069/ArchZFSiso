#!/bin/bash

sudo pacman -Syu --noconfirm archiso base-devel git

cd $1

CONFIG_DIR=$(pwd)
echo All iso config in ${CONFIG_DIR}/ISOBUILD

cd $CONFIG_DIR
rm -rf ISOBUILD && mkdir ISOBUILD
cp -r /usr/share/archiso/configs/releng/ ISOBUILD/ && mv ISOBUILD/releng ISOBUILD/zfsiso

cd ${CONFIG_DIR}/ISOBUILD
git clone https://aur.archlinux.org/zfs-dkms.git && \
	cd zfs-dkms && \
	makepkg --skippgpcheck

cd ${CONFIG_DIR}/ISOBUILD
git clone https://aur.archlinux.org/zfs-utils.git && \
	cd zfs-utils && \
	makepkg --skippgpcheck

cd ${CONFIG_DIR}/ISOBUILD/zfsiso && mkdir zfsrepo && cd zfsrepo && \
	cp ${CONFIG_DIR}/ISOBUILD/zfs-dkms/*.zst . && \
	cp ${CONFIG_DIR}/ISOBUILD/zfs-utils/*.zst . && \
	repo-add zfsrepo.db.tar.gz *.zst

echo "# ZFS custom repo" >> ${CONFIG_DIR}/ISOBUILD/zfsiso/packages.x86_64 && \
    echo "linux-headers" >> ${CONFIG_DIR}/ISOBUILD/zfsiso/packages.x86_64 && \
    echo "zfs-dkms" >> ${CONFIG_DIR}/ISOBUILD/zfsiso/packages.x86_64 && \
    echo "zfs-utils" >> ${CONFIG_DIR}/ISOBUILD/zfsiso/packages.x86_64 && \
	echo "fastfetch" >> ${CONFIG_DIR}/ISOBUILD/zfsiso/packages.x86_64

cd ${CONFIG_DIR}/ISOBUILD/zfsiso && \
    echo "#" && \
    echo "[zfsrepo]" >> pacman.conf && \
    echo "SigLevel = Optional TrustAll" >> pacman.conf && \
    echo "Server = file://${CONFIG_DIR}/ISOBUILD/zfsiso/zfsrepo" >> pacman.conf

mkdir -p ${CONFIG_DIR}/ISOBUILD/zfsiso/{WORK,ISOOUT}

sudo mkarchiso -v -w ${CONFIG_DIR}/ISOBUILD/zfsiso/WORK -o ${CONFIG_DIR}/ISOBUILD/zfsiso/ISOOUT ${CONFIG_DIR}/ISOBUILD/zfsiso/

if [ $? -eq 0 ]; then
	echo Build finished, iso in ${CONFIG_DIR}/ISOBUILD/zfsiso/ISOOUT
fi
