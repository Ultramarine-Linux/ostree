registry_auth := "auth.json"
ostree_cache := "cache"

prep:
  [ -d {{ostree_cache}} ] || mkdir -p {{ostree_cache}}

clean-cache:
  sudo rm -rf {{ ostree_cache }}

clean-out:
  rm -rf ./out

clean: clean-cache clean-out

compile: clean-out
  melody compile ultramarine/core.yaml out

compose:
  sudo rpm-ostree compose image --format=registry --cachedir={{ostree_cache}} --authfile={{registry_auth}} --initialize out/0.yaml ghcr.io/ultramarine-linux/ultramarine-ostree:38

compose-registry:
  sudo rpm-ostree compose image --cachedir={{ostree_cache}} --initialize out/0.yaml image

build: prep compile compose
build-registry: prep compile compose-registry
