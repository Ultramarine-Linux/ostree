prep:
  mkdir -p ./cache
  ostree init --repo=ostree archive

clean-repo:
  sudo rm -rf ./ostree

clean-cache:
  sudo rm -rf ./cache

clean-out:
  sudo rm -rf ./out

clean: clean-repo clean-cache clean-out

compile: clean-out
  melody compile ultramarine/core.yaml out


compose: prep
  sudo rpm-ostree compose tree --repo=ostree --cachedir=cache out/0.yaml
  sudo chown -R $USER ostree
  sudo chown -R $USER cache

build: prep compile compose