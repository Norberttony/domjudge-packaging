#!/bin/bash

set -euo pipefail

# Usage: https://github.com/DOMjudge/domjudge/blob/main/misc-tools/dj_make_chroot.in#L58-L87
/opt/domjudge/judgehost/bin/dj_make_chroot

# remove packages
/opt/domjudge/judgehost/bin/dj_run_chroot "
apt remove pypy3 && apt autoremove
"

# repository updates
/opt/domjudge/judgehost/bin/dj_run_chroot "
apt update && apt install -y software-properties-common curl gnupg &&
add-apt-repository ppa:pypy/ppa -y &&
add-apt-repository ppa:deadsnakes/ppa -y &&
curl -fsSL https://deb.nodesource.com/setup_24.x | bash -
"

# install packages
/opt/domjudge/judgehost/bin/dj_run_chroot "
apt update && apt install -y --no-install-recommends --no-install-suggests nodejs &&
apt autoremove -y && apt clean &&
rm -rf /tmp/*
"

cd /chroot/domjudge/usr/local/lib
sudo apt update && sudo apt install -y curl
# get latest pypy version that uses python 3.12 (currently not available in repositories)
curl -fsSL "https://downloads.python.org/pypy/pypy3.12-v8.0.1-linux64.tar.gz" | tar xz

# set up symlink to pypy in chroot
cd /
/opt/domjudge/judgehost/bin/dj_run_chroot "
ln -s /usr/local/lib/pypy3.12-v8.0.1-linux64/bin/pypy3 /usr/local/bin/pypy3
"

cd /
echo "[..] Compressing chroot"
tar -czpf /chroot.tar.gz --exclude=/chroot/tmp --exclude=/chroot/proc --exclude=/chroot/sys --exclude=/chroot/mnt --exclude=/chroot/media --exclude=/chroot/dev --one-file-system /chroot
echo "[..] Compressing judge"
tar -czpf /judgehost.tar.gz /opt/domjudge/judgehost
