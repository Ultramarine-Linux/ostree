registry_auth := "auth.json"
ostree_cache := "cache"

prep:
  [ -d {{ostree_cache}} ] || mkdir -p {{ostree_cache}}

clean-cache:
  sudo rm -rf {{ ostree_cache }}

clean-variant variant:
  rm -rf ./out/{{variant}}

clean-out:
  rm -rf ./out

clean: clean-cache clean-out

compile variant: (clean-variant variant)
  melody compile ultramarine/{{variant}}.yaml out/{{variant}}

compose variant:
  sudo rpm-ostree compose image --cachedir={{ostree_cache}} --initialize out/{{variant}}/0.yaml image

compose-registry variant:
  sudo rpm-ostree compose image --format=registry --cachedir={{ostree_cache}} --authfile={{registry_auth}} --initialize out/{{variant}}/0.yaml ghcr.io/ultramarine-linux/{{variant}}-ostree:38

build variant: prep (compile variant) (compose variant)
build-registry variant: prep (compile variant) (compose-registry variant)

compile-all: (compile "base") (compile "flagship") (compile "gnome") (compile "pantheon") (compile "plasma")
build-all: (build "base") (build "flagship") (build "gnome") (build "pantheon") (build "plasma")
build-all-registry: (build-registry "base") (build-registry "flagship") (build-registry "gnome") (build-registry "pantheon") (build-registry "plasma")
