> [!IMPORTANT]
> The zfs modules may not be able to catch up the kernel release, \
> if such thing happeneds or anything broke please let me know by creating an issue

# Arch ZFS iso

This is a dockerfile and a bash script to build an archlinux installation iso with zfs modules

## How does this work

1. Setup `archlinux:base` docker image with steps in this [YT tutorial](https://youtu.be/CcSjnqreUcQ?si=iqtFt0PYebQDER6t)
2. Run the image and build it

## Build it on your own

### Using docker
```bash
docker buildx build -t archzfsiso .
docker run --privileged --rm -v "${HOME}/iso/:/ISOBUILD/zfsiso/ISOOUT" archzfsiso
```

### On bare metal(if you're on Arch or you some how setup archiso on your system)
```bash
./build.sh <dir you want the build happen>
```

## Related works

[r-maerz's archlinux-lts-zfs](https://github.com/r-maerz/archlinux-lts-zfs) \
[eoli3n's archiso-zfs](https://github.com/eoli3n/archiso-zfs)
