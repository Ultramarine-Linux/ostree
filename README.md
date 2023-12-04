# Tree files for Ultramarine and tauOS variants

[![CI - OSTree](https://github.com/Ultramarine-Linux/ostree-config/actions/workflows/ci-ostree.yml/badge.svg)](https://github.com/Ultramarine-Linux/ostree-config/actions/workflows/ci-ostree.yml)
[![CI - ISOs](https://github.com/Ultramarine-Linux/ostree-config/actions/workflows/ci-isos.yaml/badge.svg)](https://github.com/Ultramarine-Linux/ostree-config/actions/workflows/ci-isos.yaml)

These builds are currently in beta. If you are planning to test them, please [join our Discord](https://discord.gg/bUuQasHdrF) first and let us know. We'll be happy to receive feedback and assist you :)

<details>
  <summary>Downloads (please reach out on our Discord first)</summary>

  * [Nightly ISOs](https://nightly.link/Ultramarine-Linux/ostree-config/workflows/ci-isos.yaml/main?preview)
</details>

# 🛠️ Dependencies

Please make sure you have these dependencies first before building.

```
rpm-ostree
melody
just
```

Please note that building ISOs also require the following dependencies.

```
lorax
```

# 🏗️ Building

Simply clone this repo, then:

```sh
just build-image <ultramarine|tau>/<variant>
```

ISOs can be built using:

```sh
just isos/build-<ultramarine|tau> <variant>
```
