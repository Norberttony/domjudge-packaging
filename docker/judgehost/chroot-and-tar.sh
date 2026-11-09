#!/bin/bash

set -euo pipefail

# Usage: https://github.com/DOMjudge/domjudge/blob/main/misc-tools/dj_make_chroot.in#L58-L87
/opt/domjudge/judgehost/bin/dj_make_chroot

# repository updates
/opt/domjudge/judgehost/bin/dj_run_chroot "
apt update && apt install -y software-properties-common curl gnupg &&
add-apt-repository ppa:pypy/ppa -y &&
add-apt-repository ppa:deadsnakes/ppa -y &&
curl -fsSL https://deb.nodesource.com/setup_24.x | bash -
"

# install packages
/opt/domjudge/judgehost/bin/dj_run_chroot "
apt update && apt install -y --no-install-recommends --no-install-suggests nodejs python3.15 pypy3  &&
apt autoremove -y && apt clean &&
rm -rf /tmp/*
"

cd /
echo "[..] Compressing chroot"
tar -czpf /chroot.tar.gz --exclude=/chroot/tmp --exclude=/chroot/proc --exclude=/chroot/sys --exclude=/chroot/mnt --exclude=/chroot/media --exclude=/chroot/dev --one-file-system /chroot
echo "[..] Compressing judge"
tar -czpf /judgehost.tar.gz /opt/domjudge/judgehost
