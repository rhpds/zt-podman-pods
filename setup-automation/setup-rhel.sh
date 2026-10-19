#!/bin/bash
set -x
trap 'echo "FATAL: setup failed at line ${LINENO}" >> /tmp/progress.log; exit 1' ERR

echo "Adding wheel" > /root/post-run.log
usermod -aG wheel rhel

echo "Setup zt-podman-pods" > /tmp/progress.log
chmod 666 /tmp/progress.log

dnf -y remove katello-ca-consumer-* 2>/dev/null || true
subscription-manager clean
subscription-manager register --activationkey="${ACTIVATION_KEY}" --org="${ORG_ID}" --force
dnf install -y git podman

LIBDIR=/tmp/lab-lib-$$
git clone --depth=1 https://github.com/rhel-labs/lab-setup "${LIBDIR}"
. "${LIBDIR}/common.sh"

echo "Packages installed" >> /tmp/progress.log

# --- lab configuration ---
# This lab pulls public images only — no private registry, no secrets beyond registration.
# -------------------------

# Pre-pull the lab images into the rhel user's storage
pull_public_images rhel \
    registry.access.redhat.com/hi/httpd:latest \
    registry.access.redhat.com/hi/valkey:latest \
    registry.access.redhat.com/hi/curl:latest
echo "Lab images staged in rhel user storage" >> /tmp/progress.log

cleanup_subscription
cleanup_tmpfiles
echo "Setup complete" >> /tmp/progress.log
