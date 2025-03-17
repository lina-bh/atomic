FROM quay.io/fedora-ostree-desktops/kinoite:41
RUN mkdir -p /var/lib/alternatives

RUN echo 'add_dracutmodules+=" fido2  "' > /usr/lib/dracut/dracut.conf.d/89-fido2.conf && ostree container commit

ADD https://raw.githubusercontent.com/coreos/fedora-coreos-config/refs/heads/stable/overlay.d/05core/usr/lib/systemd/system-generators/coreos-sulogin-force-generator /usr/lib/systemd/system-generators/
RUN chmod 0744 /usr/lib/systemd/system-generators/coreos-sulogin-force-generator && ostree container commit
RUN systemctl disable flatpak-add-fedora-repos.service && ostree container commit

RUN --mount=type=cache,target=/var/cache/libdnf5 \
    dnf5 -y --setopt=install_weak_deps=False install neovim && ostree container commit

RUN --mount=type=cache,target=/var/cache/libdnf5 \
    dnf5 -y config-manager addrepo --overwrite --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo && \
    dnf5 -y install tailscale && \
    dnf5 -y config-manager setopt "*tailscale*".enabled=0 && \
    systemctl enable tailscaled.service && \
    ostree container commit

# RUN --mount=type=cache,target=/var/cache/libdnf5 \
#     dnf5 -y copr enable ublue-os/packages && \
#     dnf5 -y copr enable ublue-os/staging && \
#     dnf5 -y install \
#     android-udev-rules \
#     ublue-os-media-automount-udev \
#     ublue-os-udev-rules \
#     ublue-os-update-services \ 
#     && \
#     dnf5 -y copr disable ublue-os/staging && \
#     dnf5 -y copr disable ublue-os/packages && \
#     systemctl disable flatpak-system-update && \
#     systemctl disable --global flatpak-user-update && \
#     ostree container commit
RUN printf '[Daemon]\nAutomaticUpdatePolicy=stage\nLockLayering=true\n' > /etc/rpm-ostreed.conf && \
    systemctl enable rpm-ostreed-automatic.timer && \
    dnf5 -y remove plasma-discover-rpm-ostree && \
    ostree container commit

RUN --mount=type=cache,target=/var/cache/libdnf5 \
    dnf5 -y config-manager addrepo --overwrite --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo && \
    dnf5 -y install ffmpeg libav{codec,device,filter,format,util} libpostproc libsw{resample,scale} && \
    dnf5 -y versionlock add ffmpeg libav{codec,device,filter,format,util} libpostproc libsw{resample,scale} && \
    dnf5 -y config-manager setopt '*fedora-multimedia*'.enabled=0 && \
    ostree container commit

RUN --mount=type=cache,target=/var/cache/libdnf5 \
    rpm --import https://repos.fyralabs.com/terra41/key.asc && \
    dnf5 -y install --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release{,-extras} && \
    dnf5 -y config-manager setopt terra-mesa.enabled=1 '*terra*'.repo_gpgcheck=0 && \
    dnf5 -y --setopt=install_weak_deps=False install steam && \
    dnf5 -y config-manager setopt "*terra*".enabled=0 && \
    dnf5 -y versionlock add mesa-filesystem mesa-{dri,va,vulkan}-drivers mesa-lib{GL,EGL,gbm} && \
    ostree container commit

RUN --mount=type=cache,target=/var/cache/libdnf5 \
    dnf5 -y install \
    fish \
    gamescope \
    mangohud \
    wl-clipboard \
    solaar-udev \
    duperemove \
    libvirt \
    libvirt-nss \
    qemu-system-{x86,aarch64} \
    qemu-user-binfmt \
    gcc \
    make \
    chromium \
    dejavu-lgc-fonts-all \
    && \
    ostree container commit

RUN dnf5 -y remove krfb krfb-libs kfind kcharselect && ostree container commit

LABEL containers.bootc=1
