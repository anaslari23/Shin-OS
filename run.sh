#!/bin/sh
# Boot Shin in QEMU (Apple Silicon, HVF). Serial console in this terminal, screen in a window.
cd "$(dirname "$0")"
V=v3.24
M=http://dl-cdn.alpinelinux.org/alpine
python3 -m http.server 8000 --directory dist --bind 127.0.0.1 >/dev/null 2>&1 &
trap 'kill $!' EXIT
qemu-system-aarch64 -M virt,highmem=on -accel hvf -cpu host -smp 4 -m 2G \
  -kernel dist/vmlinuz-virt -initrd dist/initramfs-virt \
  -append "console=ttyAMA0 ip=dhcp alpine_repo=$M/$V/main,$M/$V/community modloop_verify=no modloop=$M/latest-stable/releases/aarch64/netboot/modloop-virt apkovl=http://10.0.2.2:8000/shin.apkovl.tar.gz" \
  -netdev user,id=n0 -device virtio-net-pci,netdev=n0 \
  -device virtio-gpu-pci,xres=540,yres=1080 -device virtio-keyboard-pci -device virtio-tablet-pci \
  -display ${QDISPLAY:-cocoa} -serial ${SERIAL:-mon:stdio} "$@"
