ARG FED=41

FROM ghcr.io/ublue-os/bazzite:${FED} AS kernel

COPY build.sh /tmp/build.sh
ADD https://download.docker.com/linux/fedora/docker-ce.repo /etc/yum.repos.d
RUN mkdir -p /var/lib/alternatives && bash /tmp/build.sh && ostree container commit
