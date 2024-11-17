#!/bin/bash

set -ouex pipefail
cd "$(dirname "$0")"

RELEASE="$(rpm -E %fedora)"

# https://github.com/ublue-os/bluefin/blob/f833e1f6a5d1863b26e6f24a5ec28068d511b3de/build_files/shared/build-base.sh

# Copy Files to Container
cp -rv /bluefin/just /tmp/just
cp -v bluefin/system_files/shared/etc/yum.repos.d/tailscale.repo /etc/yum.repos.d
cp -rv bluefin/system_files/shared/usr/share/fonts/inter /usr/share/fonts
mkdir -p /usr/share/just
cp -v bluefin/system_files/shared/usr/share/just/* /usr/share/just
cp -v bluefin/system_files/dx/usr/lib/systemd/system/*.service /usr/lib/systemd/system
cp -v bluefin/system_files/dx/usr/lib/systemd/tmpfiles.d/*.conf /usr/lib/systemd/tmpfiles.d
cp -v bluefin/system_files/dx/etc/yum.repos.d/vscode.repo /etc/yum.repos.d

./bluefin/build_files/base/00-build-fix.sh
./bluefin/build_files/base/02-install-copr-repos.sh

#rpm --import https://downloads.1password.com/linux/keys/1password.asc
echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo

rpm-ostree uninstall \
    firefox \
    firefox-langpacks \
    ublue-os-update-services \
    krfb \
    krfb-libs \
    plasma-welcome \
    plasma-discover
rpm-ostree install \
    1password \
    1password-cli \
    breeze-gtk \
    chromium \
    code \
    edk2-ovmf \
    firewall-config \
    gcc \
    gcc \
    input-remapper \
    kdialog \
    konsole \
    libvirt \
    libvirt-nss \
    nerdfonts \
    qemu \
    qemu-char-spice \
    qemu-img \
    qemu-system-x86-core \
    qemu-user-binfmt \
    qemu-user-static \
    tailscale \
    virt-manager
    wl-clipboard

./bluefin/build_files/base/05-override-install.sh

systemctl enable tailscaled
systemctl enable podman.socket
systemctl enable swtpm-workaround
systemctl enable libvirt-workaround
systemctl disable pmie
systemctl disable pmlogger

./bluefin/build_files/base/18-workarounds.sh

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
rpm-ostree install chromium

# this would install a package from rpmfusion
# rpm-ostree install vlc

#### Example for enabling a System Unit File

systemctl enable podman.socket
