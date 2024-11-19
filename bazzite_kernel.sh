#!/bin/bash
set -xeuo pipefail
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
exec ostree container commit
