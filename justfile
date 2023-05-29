clean-out:
  rm -rf ./out

clean: clean-out

compile: clean-out
  melody compile ultramarine/core.yaml out

compose:
  sudo rpm-ostree compose image --format=registry out/0.yaml ghcr.io/ultramarine-linux/ultramarine-ostree:38 --initialize

build: compile compose
