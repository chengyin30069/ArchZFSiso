FROM archlinux:latest

RUN pacman -Syu --noconfirm reflector rsync && \
    rm /var/cache/pacman/pkg/*

RUN rm /etc/pacman.d/mirrorlist && \
    reflector -f 10 -c Taiwan >> /etc/pacman.d/mirrorlist

RUN pacman -S --noconfirm archiso sudo base-devel git && \
    rm /var/cache/pacman/pkg/*

RUN useradd -m -G wheel -s /bin/bash builduser && \
    echo "builduser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

WORKDIR /ISOBUILD

RUN cd / && cp -r /usr/share/archiso/configs/releng/ ISOBUILD/ && mv ISOBUILD/releng ISOBUILD/zfsiso

RUN chown -R builduser:builduser /ISOBUILD

USER builduser

RUN git clone https://aur.archlinux.org/zfs-dkms.git && \
    cd zfs-dkms && \
    makepkg --skippgpcheck

RUN git clone https://aur.archlinux.org/zfs-utils.git && \
    cd zfs-utils && \
    makepkg --skippgpcheck

USER root

RUN cd zfsiso && mkdir zfsrepo && cd zfsrepo && \
    cp /ISOBUILD/zfs-dkms/*.zst . && \
    cp /ISOBUILD/zfs-utils/*.zst . && \
    repo-add zfsrepo.db.tar.gz *.zst

RUN echo "# ZFS custom repo" >> /ISOBUILD/zfsiso/packages.x86_64 && \
    echo "linux-headers" >> /ISOBUILD/zfsiso/packages.x86_64 && \
    echo "zfs-dkms" >> /ISOBUILD/zfsiso/packages.x86_64 && \
    echo "zfs-utils" >> /ISOBUILD/zfsiso/packages.x86_64

RUN cd /ISOBUILD/zfsiso && \
    echo "#" && \
    echo "[zfsrepo]" >> pacman.conf && \
    echo "SigLevel = Optional TrustAll" >> pacman.conf && \
    echo "Server = file:///ISOBUILD/zfsiso/zfsrepo" >> pacman.conf

RUN mkdir -p /ISOBUILD/zfsiso/{WORK,ISOOUT}

RUN chown -R builduser:builduser /ISOBUILD

RUN mkdir -p /run/shm

#RUN cd zfsiso && \
#    mkarchiso -v -w WORK -o ISOOUT .
