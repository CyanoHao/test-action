#!/bin/bash

set -euxo pipefail

print_ok() {
  echo -e "\033[32m[OK] $1\033[0m"
}

print_err() {
  echo -e "\033[31m[ERR] $2\033[0m"
}

create_layers() {
  for i in $(seq 1 5); do
    mkdir -p "/tmp/overlay/layer$i"
    echo "layer$i" > "/tmp/overlay/layer$i/layer.txt"
  done
  mkdir -p /tmp/overlay/merged
}

test_overlay_1() {
  mount -t overlay overlay /tmp/overlay/merged -o lowerdir=/tmp/overlay/layer1:/tmp/overlay/layer2
  if [[ $(cat /tmp/overlay/merged/layer.txt) == "layer1" ]]; then
    print_ok "test_overlay_1 okay, content of merged directory is layer1"
  else
    print_err "test_overlay_1 failed, content of merged directory:"
    cat /tmp/overlay/merged/layer.txt
  fi
}

test_overlay_2() {
  mount -t overlay overlay /tmp/overlay/merged -o lowerdir=/tmp/overlay/layer3:/tmp/overlay/merged
  if [[ $(cat /tmp/overlay/merged/layer.txt) == "layer3" ]]; then
    print_ok "test_overlay_2 okay, content of merged directory is layer3"
  else
    print_err "test_overlay_2 failed, content of merged directory:"
    cat /tmp/overlay/merged/layer.txt
  fi
}

create_layers
test_overlay_1
test_overlay_2
