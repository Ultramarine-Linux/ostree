registry_auth := "auth.json"
ostree_cache := "cache"
ostree_repo := "ostree-repo"
initialize := "--initialize"

prep:
  [ -d {{ostree_cache}} ] || mkdir -p {{ostree_cache}}
  [ -d {{ostree_repo}} ] || ostree init --repo={{ostree_repo}}

clean-cache:
  sudo rm -rf {{ ostree_cache }}

clean-variant variant:
  rm -rf ./out/{{variant}}

clean-out:
  rm -rf ./out

clean-repo:
  rm -rf ./{{ostree_repo}}

clean: clean-cache clean-out clean-repo

compile variant: (clean-variant variant)
  melody compile {{variant}}.yaml out/{{variant}}

compose-tree variant:
  sudo rpm-ostree compose tree --cachedir={{ostree_cache}} --repo={{ostree_repo}} --unified-core out/{{variant}}/0.yaml

compose-image variant:
  sudo rpm-ostree compose image --cachedir={{ostree_cache}} {{initialize}} out/{{variant}}/0.yaml image

compose-registry variant:
  sudo rpm-ostree compose image --format=registry --cachedir={{ostree_cache}} --copy-retry-times=20 --authfile={{registry_auth}} {{initialize}} out/{{variant}}/0.yaml ghcr.io/ultramarine-linux/{{variant}}-ostree:38

build-tree variant: prep (compile variant) (compose-tree variant)
build-image variant: prep (compile variant) (compose-image variant)
build-registry variant: prep (compile variant) (compose-registry variant)

compile-all: (compile "ultramarine/base") (compile "ultramarine/flagship") (compile "ultramarine/gnome") (compile "ultramarine/pantheon") (compile "ultramarine/plasma") (compile "tau/home")
build-all-tree: (build-tree "ultramarine/base") (build-tree "ultramarine/flagship") (build-tree "ultramarine/gnome") (build-tree "ultramarine/pantheon") (build-tree "ultramarine/plasma") (build-tree "tau/home")
build-all-image: (build-image "ultramarine/base") (build-image "ultramarine/flagship") (build-image "ultramarine/gnome") (build-image "ultramarine/pantheon") (build-image "ultramarine/plasma") (build-image "tau/home")
build-all-registry: (build-registry "ultramarine/base") (build-registry "ultramarine/flagship") (build-registry "ultramarine/gnome") (build-registry "ultramarine/pantheon") (build-registry "ultramarine/plasma") (build-registry "tau/home")
