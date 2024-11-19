ARG FED=41

FROM ghcr.io/ublue-os/bazzite-kernel:${FED} AS kernel
FROM ghcr.io/ublue-os/aurora-dx:${FED}

ARG onepassword_gid=59999
ARG onepassword_cli_gid=59998

# https://github.com/blue-build/modules/blob/c0943c009d578214d8bd3d6f185a106420dc034e/modules/bling/installers/1password.sh
COPY 1password.repo /etc/yum.repos.d
COPY 1password.desktop /etc/skel/.config/autostart
COPY op-quick-access.desktop /usr/share/applications
COPY op-quick-access.desktop /usr/share/kglobalaccel
RUN --mount=type=cache,target=/var/cache/rpm-ostree \
    --mount=type=bind,from=kernel,source=/tmp/rpms,target=/tmp/rpms \
    rm -v /etc/yum.repos.d/hikariknight-looking-glass-kvmfr-fedora-41.repo && \
    rpm --import https://downloads.1password.com/linux/keys/1password.asc && \
    rpm --import https://dl.google.com/linux/linux_signing_key.pub && \
    sed -i 's/enabled=0/enabled=1/' /etc/yum.repos.d/google-chrome.repo && \ 
    mkdir -p /var/lib/alternatives /var/opt && \
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
    kmod-kvmfr \
    && rpm-ostree override replace -C --experimental /tmp/rpms/*.rpm \
    && rpm-ostree install \
    google-chrome-stable \
    chromium \
    konsole \
    gnome-disk-utility \
    1password \
    1password-cli \
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
    && rm -v /etc/yum.repos.d/1password.repo /etc/yum.repos.d/google-chrome.repo \
    && mv /var/opt/1Password /usr/lib/opt/ \
    && echo 'L /opt/1Password - - - - /usr/lib/opt/1Password' >/usr/lib/tmpfiles.d/opt-1password.conf \
    && rm -v /usr/lib/sysusers.d/*onepassword* \
    && echo "g onepassword ${onepassword_gid}" > /usr/lib/sysusers.d/onepassword.conf \
    && chgrp ${onepassword_gid} /usr/lib/opt/1Password/1Password-BrowserSupport \
    && chmod 2755 /usr/lib/opt/1Password/1Password-BrowserSupport \
    && echo "g onepassword-cli ${onepassword_cli_gid}" > /usr/lib/sysusers.d/onepassword-cli.conf \
    && chgrp ${onepassword_cli_gid} /usr/bin/op \
    && chmod 2755 /usr/bin/op \
    && sed -i 's/NoDisplay=true/NoDisplay=false/' /usr/share/applications/org.kde.konsole.desktop \
    && mv /var/opt/google /usr/lib/opt/ \
    && echo 'L /opt/google - - - - /usr/lib/opt/google' >/usr/lib/tmpfiles.d/opt-google.conf \
    && ostree container commit

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
