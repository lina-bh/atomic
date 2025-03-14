#!/bin/bash
set -ouex pipefail

coprs="ublue-os/packages ublue-os/staging"
for copr in $coprs; do
  dnf5 -y copr enable "$copr"
done
dnf5 -y config-manager addrepo --overwrite --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
dnf5 -y install \
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
        "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

dnf5 -y install \
  ublue-os-media-automount-udev \
  ublue-os-udev-rules \
  tailscale \
  fish \
  gamescope \
  mangohud \
  wl-clipboard \
  neovim \
  solaar-udev \
  android-udev-rules \
  duperemove \
  ;
dnf5 -y --setopt=install_weak_deps=False install \
  steam \
  ;
dnf5 -y remove \
  firefox \
  firefox-langpacks \
  krfb \
  krfb-libs \
  kfind \
  ;

dnf5 -y config-manager setopt "*rpmfusion*".enabled=0
dnf5 -y config-manager setopt "*tailscale*".enabled=0
# sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/tailscale.repo
for copr in $coprs; do
  dnf5 -y copr disable "$copr"
done

echo 'add_dracutmodules+=" fido2  "' > /usr/lib/dracut/dracut.conf.d/89-fido2.conf

CSFG=/usr/lib/systemd/system-generators/coreos-sulogin-force-generator
curl -sSLo ${CSFG} https://raw.githubusercontent.com/coreos/fedora-coreos-config/refs/heads/stable/overlay.d/05core/usr/lib/systemd/system-generators/coreos-sulogin-force-generator
chmod +x ${CSFG}

systemctl enable tailscaled.service
