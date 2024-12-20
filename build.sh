#!/bin/bash
rpm --import https://download.docker.com/linux/fedora/gpg
curl -fsSL -o"/etc/yum.repos.d/docker-ce.repo" https://download.docker.com/linux/fedora/docker-ce.repo
rpm-ostree install docker-ce
