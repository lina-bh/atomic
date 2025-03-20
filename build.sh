#!/usr/bin/env bash
set -exo pipefail

name=atomic
org=lina-bh

BUILD_ARGS=()
while IFS=$'\n' read -r label; do
    BUILD_ARGS+=("--label" "$label")
done <<< "$DOCKER_METADATA_OUTPUT_LABELS" && unset label

podman build \
    "${BUILD_ARGS[@]}" \
    --pull=newer \
    --tag "${name}:latest" \
    --cache-from "ghcr.io/${org}/${name}" \
    .
for tag in $DOCKER_METADATA_OUTPUT_TAGS; do
    podman tag "${name}:latest" "${name}:${tag}"
done || :
