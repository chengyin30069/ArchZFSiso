#!/bin/bash

sudo pacman -Syu --noconfirm archiso base-devel git

cd $1

CONFIG_DIR=$(pwd)

if [ $CONFIG_DIR == "/" ]; then
	$CONFIG_DIR=""
fi

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

sed -i '/^linux$/d' ${CONFIG_DIR}/ISOBUILD/zfsiso/packages.x86_64 && \
	sed -i '/^linux-headers$/d' ${CONFIG_DIR}/ISOBUILD/zfsiso/packages.x86_64 && \
	sed -i 's/^broadcom-wl$/broadcom-wl-dkms/g' ${CONFIG_DIR}/ISOBUILD/zfsiso/packages.x86_64 && \
	echo "# ZFS custom repo" >> ${CONFIG_DIR}/ISOBUILD/zfsiso/packages.x86_64 && \
    echo "linux-lts" >> ${CONFIG_DIR}/ISOBUILD/zfsiso/packages.x86_64 && \
    echo "linux-lts-headers" >> ${CONFIG_DIR}/ISOBUILD/zfsiso/packages.x86_64 && \
    echo "zfs-dkms" >> ${CONFIG_DIR}/ISOBUILD/zfsiso/packages.x86_64 && \
    echo "zfs-utils" >> ${CONFIG_DIR}/ISOBUILD/zfsiso/packages.x86_64 && \
	echo "fastfetch" >> ${CONFIG_DIR}/ISOBUILD/zfsiso/packages.x86_64

rm /ISOBUILD/zfsiso/airootfs/etc/mkinitcpio.d/linux.preset && \
	echo "PRESETS=('archiso')" >> ${CONFIG_DIR}/ISOBUILD/zfsiso/airootfs/etc/mkinitcpio.d/linux-lts.preset && \
	echo "ALL_kver='/boot/vmlinuz-linux-lts'" >> ${CONFIG_DIR}/ISOBUILD/zfsiso/airootfs/etc/mkinitcpio.d/linux-lts.preset && \
	echo "archiso_config='/etc/mkinitcpio.conf.d/archiso.conf'" >> ${CONFIG_DIR}/ISOBUILD/zfsiso/airootfs/etc/mkinitcpio.d/linux-lts.preset && \
	echo "archiso_image=\"/boot/initramfs-linux-lts.img\"" >> ${CONFIG_DIR}/ISOBUILD/zfsiso/airootfs/etc/mkinitcpio.d/linux-lts.preset

set -eux; \
    PROFILE="/ISOBUILD/zfsiso"; \
    \
    find "${PROFILE}/efiboot/loader/entries" "${PROFILE}/syslinux" "${PROFILE}/grub" \
        -type f \
        \( -name '*.conf' -o -name '*.cfg' \) \
        -print0 | \
    xargs -0 -r sed -i \
        -e 's#vmlinuz-linux#vmlinuz-linux-lts#g' \
        -e 's#initramfs-linux.img#initramfs-linux-lts.img#g' \
        -e 's#Arch Linux install medium#Arch Linux LTS + ZFS install medium#g'


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
