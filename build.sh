#!/bin/bash
rpm --import https://download.docker.com/linux/fedora/gpg
rpm --import https://download.copr.fedorainfracloud.org/results/peterwu/iosevka/pubkey.gpg
rpm --import https://packages.microsoft.com/keys/microsoft.asc
rpm-ostree install docker-ce
