FROM quay.io/fedora-ostree-desktops/kinoite:41
RUN mkdir -p /var/lib/alternatives

RUN echo 'add_dracutmodules+=" fido2  "' > /usr/lib/dracut/dracut.conf.d/89-fido2.conf && ostree container commit

ADD https://raw.githubusercontent.com/coreos/fedora-coreos-config/refs/heads/stable/overlay.d/05core/usr/lib/systemd/system-generators/coreos-sulogin-force-generator /usr/lib/systemd/system-generators/
RUN chmod 0744 /usr/lib/systemd/system-generators/coreos-sulogin-force-generator && ostree container commit
RUN systemctl disable flatpak-add-fedora-repos.service && ostree container commit

RUN systemctl enable --global podman.socket && ostree container commit

RUN authselect enable-feature with-fingerprint && \
    authselect enable-feature with-systemd-homed && \
    ostree container commit

ADD ./rpm-ostreed.conf /etc/
ADD ./bootc-fetch-apply-updates.service.d /usr/lib/systemd/system/
RUN ostree container commit

RUN --mount=type=cache,target=/var/cache/libdnf5 \
    dnf5 -y --setopt=install_weak_deps=False install neovim && ostree container commit

RUN --mount=type=cache,target=/var/cache/libdnf5 \
    dnf5 -y config-manager addrepo --overwrite --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo && \
    dnf5 -y install tailscale && \
    dnf5 -y config-manager setopt "*tailscale*".enabled=0 && \
    systemctl enable tailscaled.service && \
    ostree container commit

# ffmpeg
RUN --mount=type=cache,target=/var/cache/libdnf5 \
    dnf5 -y config-manager addrepo --overwrite --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo && \
    dnf5 -y install ffmpeg libav{codec,device,filter,format,util} libpostproc libsw{resample,scale} && \
    dnf5 -y versionlock add ffmpeg libav{codec,device,filter,format,util} libpostproc libsw{resample,scale} && \
    dnf5 -y config-manager setopt '*fedora-multimedia*'.enabled=0 && \
    ostree container commit

# mesa all in one go
RUN --mount=type=cache,target=/var/cache/libdnf5 \
    rpm --import https://repos.fyralabs.com/terra41/key.asc && \
    dnf5 -y install --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release{,-extras} && \
    dnf5 -y config-manager setopt terra-mesa.enabled=1 terra-mesa.priority=0 '*terra*'.repo_gpgcheck=0 && \
    dnf5 -y --repo=terra-mesa swap mesa-filesystem mesa-filesystem && \
    dnf5 -y install mesa-filesystem.i686 mesa-{dri,va,vulkan}-drivers.i686 mesa-lib{GL,EGL,gbm}.i686 && \
    dnf5 -y versionlock add mesa-filesystem mesa-{dri,va,vulkan}-drivers mesa-lib{GL,EGL,gbm} && \
    dnf5 -y config-manager setopt '*terra*'.enabled=0 && \
    ostree container commit

# then steam
RUN --mount=type=cache,target=/var/cache/libdnf5 dnf5 -y --setopt=install_weak_deps=0 --setopt=terra.enabled=1 install steam && ostree container commit

RUN --mount=type=cache,target=/var/cache/libdnf5 \
    dnf5 -y copr enable wezfurlong/wezterm-nightly && \
    dnf5 -y install wezterm && \
    dnf5 -y copr disable wezfurlong/wezterm-nightly && \
    ostree container commit

RUN --mount=type=cache,target=/var/cache/libdnf5 \
    dnf5 -y copr enable bieszczaders/kernel-cachyos-addons && \
    dnf5 -y install scx-scheds scx-manager && \
    dnf5 -y copr disable bieszczaders/kernel-cachyos-addons && \
    ostree container commit

RUN --mount=type=cache,target=/var/cache/libdnf5 \
    dnf5 -y install \
    fish \
    wl-clipboard \
    solaar-udev \
    duperemove \
    python-libdnf5 \
    gamescope \
    mangohud \
    dejavu-lgc-fonts-all \
    make \
    openssl-devel \
    htop \
    gnome-disk-utility \
    && ostree container commit
RUN --mount=type=cache,target=/var/cache/libdnf5 dnf5 -y install gcc && ostree container commit
RUN --mount=type=cache,target=/var/cache/libdnf5 dnf5 -y install chromium && ostree container commit
RUN --mount=type=cache,target=/var/cache/libdnf5 \
    dnf5 -y install \
    libvirt \
    libvirt-nss \
    qemu-system-{x86,aarch64} \
    qemu-user-binfmt \
    && ostree container commit

RUN dnf5 -y remove krfb krfb-libs kfind kcharselect plasma-discover-rpm-ostree && ostree container commit

LABEL containers.bootc=1
