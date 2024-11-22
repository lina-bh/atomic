ARG FED=41

FROM ghcr.io/ublue-os/bazzite-kernel:${FED} AS kernel
FROM ghcr.io/ublue-os/aurora-dx:${FED}

COPY 1password.repo /etc/yum.repos.d
RUN mkdir -p /var/lib/alternatives /var/opt && \
    rm -v /etc/yum.repos.d/hikariknight-looking-glass-kvmfr-fedora-*.repo && \
    sed -i 's/enabled=0/enabled=1/' /etc/yum.repos.d/google-chrome.repo && \
    rpm --import https://downloads.1password.com/linux/keys/1password.asc && \
    rpm --import https://dl.google.com/linux/linux_signing_key.pub && \
    ostree container commit

RUN --mount=type=cache,target=/var/cache/rpm-ostree \
    rpm-ostree install konsole && \
    sed -i 's/NoDisplay=true/NoDisplay=false/' /usr/share/applications/org.kde.konsole.desktop && \
    ostree container commit

COPY 1password.desktop /etc/skel/.config/autostart
COPY op-quick-access.desktop /usr/share/applications
COPY op-quick-access.desktop /usr/share/kglobalaccel
COPY install_1password.sh /tmp/install_1password.sh
RUN --mount=type=cache,target=/var/cache/rpm-ostree \
    bash </tmp/install_1password.sh

COPY bazzite_kernel.sh /tmp
RUN --mount=type=cache,target=/var/cache/rpm-ostree \
    --mount=type=bind,from=kernel,source=/tmp/rpms,target=/tmp/rpms \
    bash /tmp/bazzite_kernel.sh

RUN --mount=type=cache,target=/var/cache/rpm-ostree \
    rpm-ostree install gnome-disk-utility \
    && rpm-ostree override remove -C \
    ptyxis \
    input-leap \
    solaar-udev \
    solaar \
    sysprof \
    skanpage \
    krdp \
    kde-partitionmanager \
    kcharselect \
    kfind \
    gum \
    incus \
    incus-agent \
    virt-v2v \
    virt-viewer \
    fzf \
    akonadi-server-mysql \
    akonadi-server \
    plasma-wallpapers-dynamic-builder-fish-completion \
    fish \
    bpftop \
    nvidia-gpu-firmware \
    && ostree container commit

COPY install_chrome.sh /tmp
RUN --mount=type=cache,target=/var/cache/rpm-ostree \
    bash /tmp/install_chrome.sh

RUN rm -v /etc/yum.repos.d/1password.repo /etc/yum.repos.d/google-chrome.repo && ostree container commit

# eduroam
# TODO: make this more targeted to wireless security
COPY legacy.conf /etc/pki/tls/openssl.d/
RUN ostree container commit

# https://github.com/DeterminateSystems/nix-installer/issues/1297
# ENV NIX_INSTALLER_EXTRA_CONF="extra-trusted-users = @wheel\n"
# ENV NIX_INSTALLER_NO_CONFIRM=true
# ENV NIX_INSTALLER_START_DAEMON=false
# RUN set -o pipefail && \
#     curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
#     sh -s -- install ostree --no-start-daemon

# starship

# COPY build.sh /tmp/build.sh
# RUN mkdir -p /var/lib/alternatives && \
#     bash /tmp/build.sh && \
#     ostree container commit
## NOTES:
# - /var/lib/alternatives is required to prevent failure with some RPM installs
# - All RUN commands must end with ostree container commit
#   see: https://coreos.github.io/rpm-ostree/container/#using-ostree-container-commit
