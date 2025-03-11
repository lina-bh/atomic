#!/bin/bash
set -ouex pipefail

coprs="ublue-os/packages bieszczaders/kernel-cachyos-addons"
for copr in $coprs; do
  dnf5 -y copr enable "$copr"
done
dnf5 -y config-manager addrepo --overwrite --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
# dnf5 -y install --nogpgcheck --repofrompath "terra,https://repos.fyralabs.com/terra\$releasever" terra-release{,-extras}

dnf5 -y install \
  ublue-os-luks \
  ublue-os-udev-rules \
  tailscale \
  ;

sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/tailscale.repo
for copr in $coprs; do
  dnf5 -y copr disable "$copr"
done

CSFG=/usr/lib/systemd/system-generators/coreos-sulogin-force-generator
curl -sSLo ${CSFG} https://raw.githubusercontent.com/coreos/fedora-coreos-config/refs/heads/stable/overlay.d/05core/usr/lib/systemd/system-generators/coreos-sulogin-force-generator
chmod +x ${CSFG}

systemctl enable tailscaled.service
