#!/usr/bin/env bash

# WORKDIR="$PWD"
TOPDIR="sysroot"

case $1 in
  -n|--name)
    TOPDIR="$2"
    ;;
  -*|--*)
    echo "Unknown option $1"
    exit 1
    ;;
esac

FHS_SKELETON=( ${TOPDIR}/{bin,boot,dev,lib,sbin} )
FHS_SKELETON+=( ${TOPDIR}/etc/{opt,init.d} )
FHS_SKELETON+=( ${TOPDIR}/{home,media,mnt,opt,proc,root,run,srv,sys,tmp} )
FHS_SKELETON+=( ${TOPDIR}/usr/{bin,include,lib,local,sbin,share,src} )
FHS_SKELETON+=( ${TOPDIR}/var/{cache,lock,log,opt,tmp} )

# Create the ROOT file structure
# mkdir -v -p "${FHS_SKELETON[@]}" && chmod a+rwxt "${TOPDIR}"/tmp && ln -s usr/{bin,sbin,lib} "${TOPDIR}" || exit 1
mkdir -v -p "${FHS_SKELETON[@]}" && chmod a+rwxt "${TOPDIR}"/tmp || exit 1

# Write template init script. Runs as pid 1 from initramfs to set up and hand off system.
##################################################################
cat > "${TOPDIR}"/init << 'EOF' &&
#!/bin/sh

export HOME=/home PATH=/bin:/sbin

# Mounts
if [ -d dev ]; then
  mount -t devtmpfs dev dev || mdev -s
fi
if [ -d dev ]; then
  mountpoint -q dev/pts || mount -t devpts dev/pts dev/pts
fi
if [ -d dev ]; then
  mountpoint -q proc || mount -t proc proc proc
fi
if [ -d dev ]; then
  mountpoint -q sys || mount -t sysfs sys sys
fi

# Networking
## loopback device
ip link add lo type dummy
ip addr add 127.0.0.1/32 dev lo
ip link set lo up

cat <<'!!!'

Boot took $(cut -d' ' -f1 /proc/uptime) seconds

______  ___  ___  ____   ___   __
| ___ \/ _ \ |  \/  | | | \ \ / /
| |_/ / /_\ \| .  . | | | |\ V /
|    /|  _  || |\/| | | | |/   \
| |\ \| | | || |  | | |_| / /^\ \
\_| \_\_| |_/\_|  |_/\___/\/   \/


Welcome to Ramux! A tiny BusyBox-based ramfs linux

'!!!'

exec /bin/sh
EOF
chmod +x "${TOPDIR}"/init
#####################################################################

# Google's nameserver, passwd+group with special (root/nobody) accounts + guest
echo "nameserver 8.8.8.8" > "${TOPDIR}"/etc/resolv.conf &&
cat > "${TOPDIR}"/etc/passwd << 'EOF' &&
root:x:0:0:root:/root:/bin/sh
guest:x:500:500:guest:/home/guest:/bin/sh
nobody:x:65534:65534:nobody:/proc/self:/dev/null
EOF
echo -e 'root:x:0:\nguest:x:500:\nnobody:x:65534:' > "${TOPDIR}"/etc/group || exit 1

echo "Done."
