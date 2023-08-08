#!/usr/bin/env bash
set -e

BASE_ARGS=(
  # Fedora sources
  --source=https://dl.fedoraproject.org/pub/fedora/linux/releases/38/Everything/x86_64/os/
  --source=https://dl.fedoraproject.org/pub/fedora/linux/updates/38/x86_64/
  # RPM Fusion (free) sources
  --source=https://download1.rpmfusion.org/free/fedora/releases/38/Everything/x86_64/os/
  --source=https://download1.rpmfusion.org/free/fedora/updates/38/x86_64/
  # RPM Fusion (nonfree) sources
  --source=https://download1.rpmfusion.org/nonfree/fedora/releases/38/Everything/x86_64/os/
  --source=https://download1.rpmfusion.org/nonfree/fedora/updates/38/x86_64/
  # Terra sources
  --source=https://repos.fyralabs.com/terra38/
)

case $1 in
"ultramarine/base")
  lorax $BASE_ARGS \
  --product='Ultramarine Linux' \
  --rootfs-size=8 \
  --version=38 \
  --release=1 \
  --source=https://repos.fyralabs.com/um38/ \
  --installpkgs="ultramarine-release" \
  --installpkgs="ultramarine-release-flagship" \
  --installpkgs="ultramarine-repos" \
  --installpkgs="ultramarine-logos" \
  --installpkgs="ultramarine-backgrounds" \
  --installpkgs="fedora-repos" \
  --installpkgs="curl" \
  --installpkgs="unzip" \
  --add-template=$(pwd)/lorax-embed-oci.tmpl \
  --add-template=$(pwd)/lorax-configure-oci.tmpl \
  --add-template-var=ostree_source_image=docker://ghcr.io/ultramarine-linux/gnome-ostree:38 \
  --add-template-var=ostree_stateroot=ultramarine \
  --volid=Ultramarine-Base-Installer \
  --skip-branding \
  --nomacboot \
  --logfile=$(pwd)/lorax.log \
  --tmp=$(pwd)/tmp \
  $(pwd)/home-x86_64
;;
"ultramarine/flagship")
;;
"ultramarine/gnome")
;;
"ultramarine/pantheon")
;;
"ultramarineplasma")
;;
esac
