> [!IMPORTANT]
> The zfs modules may not be able to catch up the kernel release, \
> if such thing happeneds please let me know by creating an issue

# Arch ZFS iso

This is a dockerfile to compile an archlinux installation iso with zfs modules

## How does this work

1. Setup `archlinux:latest` docker image with steps in this [YT tutorial](https://youtu.be/CcSjnqreUcQ?si=iqtFt0PYebQDER6t)
2. Run the image and compile it

## Compile it yourself
```bash
docker buildx build -t archzfsiso .
docker run --privileged --rm -v "${HOME}/iso/:/ISOBUILD/zfsiso/ISOOUT" archzfsiso
```


## Related works

[r-maerz's archlinux-lts-zfs](https://github.com/r-maerz/archlinux-lts-zfs) \
[eoli3n's archiso-zfs](https://github.com/eoli3n/archiso-zfs)
