FROM quay.io/fedora-ostree-desktops/kinoite:41

COPY build.sh /tmp/build.sh
RUN mkdir -p /var/lib/alternatives && \
    /tmp/build.sh && \
    ostree container commit
