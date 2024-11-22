#!/bin/bash
set -xeuo pipefail
sed -i 's/enabled=0/enabled=1/' /etc/yum.repos.d/ublue-os-staging*.repo
rpm-ostree override remove -C \
    xpadneo-kmod-common \
    kmod-xpadneo \
    openrazer-kmod-common \
    kmod-openrazer \
    framework-laptop-kmod-common \
    kmod-framework-laptop \
    xone-kmod-common \
    kmod-xone \
    v4l2loopback \
    kmod-v4l2loopback \
    broadcom-wl \
    kmod-wl \
    kvmfr \
    kmod-kvmfr
rpm-ostree override replace -C --experimental /tmp/rpms/*.rpm
rpm-ostree install scx-scheds
rm -v /etc/yum.repos.d/ublue-os-staging*.repo
exec ostree container commit
