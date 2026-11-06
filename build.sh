#!/bin/sh
# Fetch Alpine aarch64 netboot kernel and build the "shin" overlay (apkovl).
set -e
cd "$(dirname "$0")"
V=v3.24
BASE=https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/aarch64/netboot
mkdir -p dist
for f in vmlinuz-virt initramfs-virt modloop-virt; do
  [ -s dist/$f ] || curl -fL -o dist/$f $BASE/$f
done

# overlay = everything under ./overlay, plus the generated bits below
rm -rf .ovl && cp -R overlay .ovl
mkdir -p .ovl/etc/runlevels/{sysinit,boot,default,shutdown}
link() { for s in "${@:2}"; do ln -sf /etc/init.d/$s .ovl/etc/runlevels/$1/$s; done; }
link sysinit devfs dmesg modloop udev udev-trigger hwdrivers
link boot modules sysctl hostname bootmisc syslog networking
link default seatd
link shutdown mount-ro killprocs savecache
chmod +x .ovl/usr/local/bin/*
tar -C .ovl -czf dist/shin.apkovl.tar.gz .
rm -rf .ovl
echo "built dist/ ($V)"
