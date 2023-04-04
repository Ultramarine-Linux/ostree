
ostree_cache := "cache"
ostree_repo := "ostree"


prep:
  [ -d {{ostree_cache}} ] || mkdir -p {{ostree_cache}}
  ostree init --repo={{ostree_repo}} --mode=archive
clean-repo:
  sudo rm -rf {{ostree_repo}}

clean-cache:
  sudo rm -rf {{ ostree_cache }}

clean-out:
  rm -rf ./out

clean: clean-repo clean-cache clean-out

compile: clean-out
  melody compile ultramarine/core.yaml out


compose: prep
  sudo rpm-ostree compose image --format=registry --cachedir={{ostree_cache}} out/0.yaml ghcr.io/ultramarine-linux/ultramarine-ostree:37 --initialize

build: prep compile compose
