#!/bin/bash

set -euxo pipefail

print_info() {
  echo -e "\033[32m$1\033[0m"
}

install_fuse_overlay() {
  if ! command -v fuse-overlayfs > /dev/null; then
    apt-get update
    apt-get install -y fuse-overlayfs
  fi
}

create_layers() {
  mkdir -p /tmp/overlay/gcc/bin/
  echo "gcc" > /tmp/overlay/gcc/bin/gcc.txt

  mkdir -p /tmp/overlay/libc-host/triplet/lib/
  echo "libc-host" > /tmp/overlay/libc-host/triplet/lib/libc.txt

  mkdir -p /tmp/overlay/libc-target/lib/
  echo "libc-target" > /tmp/overlay/libc-target/lib/libc.txt
}

test_overlay_1() {
  mount -t overlay overlay /tmp/overlay/merged -o lowerdir=/tmp/overlay/gcc:/tmp/overlay/libc-host

  print_info "gcc:"
  cat /tmp/overlay/merged/bin/gcc.txt

  print_info "libc:"
  cat /tmp/overlay/merged/triplet/lib/libc.txt
}

test_overlay_2() {
  fuse-overlayfs -o lowerdir=/tmp/overlay/libc-target:/tmp/overlay/merged/triplet /tmp/overlay/merged/triplet

  print_info "libc:"
  cat /tmp/overlay/merged/triplet/lib/libc.txt
}

install_fuse_overlay
create_layers
test_overlay_1
test_overlay_2
