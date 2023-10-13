# Holochain Open Dev Templates

Custom templates for the [scaffolding tool](https://github.com/holochain/scaffolding), to develop apps and modules using the holochain-open-dev style!

There are two templates available:

- `app`: fully blown app, following the open-dev patterns and with the profiles module pre-installed.
- `module`: template to build modules like the ones you can find in [open-dev](https://github.com/holochain-open-dev), with the profiles module already pre-installed.

## Using the templates

> WARNING: these templates are only compatible with holochain v0.2.x.

1a. If you are scaffolding a new project, run this:

`nix run --override-input versions 'github:holochain/holochain?dir=versions/0_2' github:holochain/holochain#hc-scaffold -- web-app --templates-url https://github.com/holochain-open-dev/templates`

1b. If you already have an existing project, run this inside a `nix develop` shell:

`hc scaffold template get https://github.com/holochain-open-dev/templates`

WARNING! If you use the app template, you will encounter [this issue](https://github.com/holochain/scaffolding/issues/135). The quick fix is to upgrade the version of `holochain_integrity_types` in the workspace's Cargo.toml.
