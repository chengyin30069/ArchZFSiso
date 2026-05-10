FROM archlinux:base AS zfs-builder

RUN pacman -Syu --noconfirm reflector rsync && \
	pacman -Scc --noconfirm

# Get faster mirrorsite, change Taiwan to where ever you live
RUN rm /etc/pacman.d/mirrorlist && \
    reflector -f 10 -c Taiwan --protocol https >> /etc/pacman.d/mirrorlist

RUN	pacman -S --noconfirm sudo base-devel git && \
	pacman -Scc --noconfirm

RUN useradd -m -G wheel -s /bin/bash builduser && \
    echo "builduser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

WORKDIR /build
RUN chown -R builduser:builduser /build

USER builduser

RUN git clone https://aur.archlinux.org/zfs-dkms.git && \
    cd zfs-dkms && \
    makepkg --skippgpcheck --noconfirm

RUN git clone https://aur.archlinux.org/zfs-utils.git && \
    cd zfs-utils && \
    makepkg --skippgpcheck --noconfirm

FROM archlinux:base AS final

RUN pacman -Syu --noconfirm reflector rsync && \
	pacman -Scc --noconfirm

# Also here
RUN rm /etc/pacman.d/mirrorlist && \
    reflector -f 10 -c Taiwan --protocol https >> /etc/pacman.d/mirrorlist

RUN	pacman -Syu --noconfirm sudo archiso && \
	pacman -Scc --noconfirm

WORKDIR /ISOBUILD

RUN cp -r /usr/share/archiso/configs/releng/ /ISOBUILD/ && mv /ISOBUILD/releng /ISOBUILD/zfsiso

COPY --from=zfs-builder /build/zfs-dkms/*.zst /ISOBUILD/zfsiso/zfsrepo/
COPY --from=zfs-builder /build/zfs-utils/*.zst /ISOBUILD/zfsiso/zfsrepo/

RUN cd /ISOBUILD/zfsiso/zfsrepo && repo-add zfsrepo.db.tar.gz *.zst

# Switch to linux-lts since zfs are often behind in develop for linux, also switch broadcom-wl to dkms version
# since it's dependent on original linux kernel
RUN sed -i '/^linux$/d' /ISOBUILD/zfsiso/packages.x86_64 && \
	sed -i '/^linux-headers$/d' /ISOBUILD/zfsiso/packages.x86_64 && \
	sed -i 's/^broadcom-wl$/broadcom-wl-dkms/g' /ISOBUILD/zfsiso/packages.x86_64 && \
	echo "# ZFS custom repo" >> /ISOBUILD/zfsiso/packages.x86_64 && \
	echo "linux-lts" >> /ISOBUILD/zfsiso/packages.x86_64 && \
    echo "linux-lts-headers" >> /ISOBUILD/zfsiso/packages.x86_64 && \
    echo "zfs-dkms" >> /ISOBUILD/zfsiso/packages.x86_64 && \
    echo "zfs-utils" >> /ISOBUILD/zfsiso/packages.x86_64 && \
	echo "fastfetch" >> /ISOBUILD/zfsiso/packages.x86_64

RUN rm /ISOBUILD/zfsiso/airootfs/etc/mkinitcpio.d/linux.preset && \
	echo "PRESETS=('archiso')" >> /ISOBUILD/zfsiso/airootfs/etc/mkinitcpio.d/linux-lts.preset && \
	echo "ALL_kver='/boot/vmlinuz-linux-lts'" >> /ISOBUILD/zfsiso/airootfs/etc/mkinitcpio.d/linux-lts.preset && \
	echo "archiso_config='/etc/mkinitcpio.conf.d/archiso.conf'" >> /ISOBUILD/zfsiso/airootfs/etc/mkinitcpio.d/linux-lts.preset && \
	echo "archiso_image=\"/boot/initramfs-linux-lts.img\"" >> /ISOBUILD/zfsiso/airootfs/etc/mkinitcpio.d/linux-lts.preset

RUN set -eux; \
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

RUN cd /ISOBUILD/zfsiso && \
    echo "#" && \
    echo "[zfsrepo]" >> pacman.conf && \
    echo "SigLevel = Optional TrustAll" >> pacman.conf && \
    echo "Server = file:///ISOBUILD/zfsiso/zfsrepo" >> pacman.conf

RUN mkdir -p /ISOBUILD/zfsiso/{WORK,ISOOUT}

CMD ["sudo", "mkarchiso", "-v", "-w", "zfsiso/WORK", "-o", "zfsiso/ISOOUT", "zfsiso/"]
