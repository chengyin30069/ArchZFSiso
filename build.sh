#!/bin/bash

sudo pacman -Syu --noconfirm archiso base-devel git



cd 
rm -rf ISOBUILD && mkdir ISOBUILD
cp -r /usr/share/archiso/configs/releng/ ISOBUILD/ && mv ISOBUILD/releng ISOBUILD/zfsiso

cd ~/ISOBUILD
git clone https://aur.archlinux.org/zfs-dkms.git && \
	cd zfs-dkms && \
	makepkg --skippgpcheck

cd ~/ISOBUILD
git clone https://aur.archlinux.org/zfs-utils.git && \
	cd zfs-utils && \
	makepkg --skippgpcheck

cd ~/ISOBUILD/zfsiso && mkdir zfsrepo && cd zfsrepo && \
	cp ~/ISOBUILD/zfs-dkms/*.zst . && \
	cp ~/ISOBUILD/zfs-utils/*.zst . && \
	repo-add zfsrepo.db.tar.gz *.zst

echo "# ZFS custom repo" >> ~/ISOBUILD/zfsiso/packages.x86_64 && \
    echo "linux-headers" >> ~/ISOBUILD/zfsiso/packages.x86_64 && \
    echo "zfs-dkms" >> ~/ISOBUILD/zfsiso/packages.x86_64 && \
    echo "zfs-utils" >> ~/ISOBUILD/zfsiso/packages.x86_64 && \
	echo "fastfetch" >> ~/ISOBUILD/zfsiso/packages.x86_64

cd ~/ISOBUILD/zfsiso && \
    echo "#" && \
    echo "[zfsrepo]" >> pacman.conf && \
    echo "SigLevel = Optional TrustAll" >> pacman.conf && \
    echo "Server = file:///ISOBUILD/zfsiso/zfsrepo" >> pacman.conf

RUN mkdir -p ~/ISOBUILD/zfsiso/{WORK,ISOOUT}

sudo mkarchiso -v -w ~/ISOBUILD/zfsiso/WORK -o ~/ISOBUILD/zfsiso/ISOOUT zfsiso/

