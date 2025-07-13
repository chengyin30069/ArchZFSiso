> [!IMPORTANT]
> The zfs modules may not be able to catch up the kernel release, if such thing happeneds please
> let me know by creating an issue

# Arch ZFS iso

This is a dockerfile to compile an archlinux installation iso with zfs modules

## How does this work

1. Boot into `archlinux:latest` docker image
2. Follow setup steps in this [YT tutorial](https://youtu.be/CcSjnqreUcQ?si=iqtFt0PYebQDER6t)
3. Run iteratively into the image and compile manually

## Compile it yourself
1. `docker buildx build -t archzfsiso .`
2. `docker run --privileged --rm -it -v "${HOME}/iso/:/ISOBUILD/zfsiso/ISOOUT" archzfsiso bash`
3. `cd zfsiso && mkarchiso -v -w WORK -O ISOOUT .`

## Related works

[Robert Maerz's archlinux-lts-zfs](https://github.com/r-maerz/archlinux-lts-zfs)
[Jonathan Kirszling's archiso-zfs](https://github.com/eoli3n/archiso-zfs)
