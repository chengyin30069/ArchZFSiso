1. `docker buildx build -t archzfsiso .`
2. `docker run --privileged --rm -it -v "${HOME}/iso/:/ISOBUILD/zfsiso/ISOOUT" archzfsiso bash`
3. `cd zfsiso && mkarchiso -v -w WORK -O ISOOUT .`