FROM ghcr.io/ublue-os/bazzite-kernel:41 AS kernel
FROM ghcr.io/ublue-os/aurora-dx:41

RUN --mount=type=cache,target=/var/cache/rpm-ostree \
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
    && ostree container commit
RUN --mount=type=cache,target=/var/cache/rpm-ostree \
    rpm-ostree override remove kvmfr kmod-kvmfr && ostree container commit

RUN --mount=type=cache,target=/var/cache/rpm-ostree \
    --mount=type=bind,from=kernel,source=/tmp/rpms,target=/tmp/rpms \
    rpm-ostree override replace -C --experimental /tmp/rpms/*.rpm && ostree container commit

# https://github.com/DeterminateSystems/nix-installer/issues/1297
# ENV NIX_INSTALLER_EXTRA_CONF="extra-trusted-users = @wheel\n"
# ENV NIX_INSTALLER_NO_CONFIRM=true
# ENV NIX_INSTALLER_START_DAEMON=false
# RUN set -o pipefail && \
#     curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
#     sh -s -- install ostree --no-start-daemon
RUN rm -v /etc/yum.repos.d/hikariknight-looking-glass-kvmfr-fedora-41.repo
RUN --mount=type=cache,target=/var/cache/rpm-ostree \
    rpm-ostree install chromium konsole gnome-disk-utility && ostree container commit
RUN --mount=type=cache,target=/var/cache/rpm-ostree \
    rpm-ostree override remove -C \
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
    docker-ce-rootless-extras \
    docker-ce \
    docker-ce-cli \
    gum \
    glow \
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
# starship

RUN mkdir /var/opt
COPY 1password.repo /etc/yum.repos.d
RUN --mount=type=cache,target=/var/cache/rpm-ostree \
    rpm --import https://downloads.1password.com/linux/keys/1password.asc && \
    rpm-ostree install 1password-cli 1password \
    && rm -v /etc/yum.repos.d/1password.repo \
    && ostree container commit
RUN mv -v /var/opt/1Password /usr/lib/opt/ \
    && ln -sv /usr/lib/opt/1Password /var/opt/1Password \
    && ostree container commit

# COPY build.sh /tmp/build.sh
# RUN mkdir -p /var/lib/alternatives && \
#     bash /tmp/build.sh && \
#     ostree container commit
## NOTES:
# - /var/lib/alternatives is required to prevent failure with some RPM installs
# - All RUN commands must end with ostree container commit
#   see: https://coreos.github.io/rpm-ostree/container/#using-ostree-container-commit
