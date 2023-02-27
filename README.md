# Holochain Open Dev Templates

Custom templates for the [scaffolding tool](https://github.com/holochain/scaffolding), to develop apps and modules using the holochain-open-dev style!

For now, only the `app` template is available. Soonish we'll add the `module` template, to allow much easier building of holochain-open-dev modules.

## Using the templates

1a. If you are scaffolding a new project, run this:

`nix-shell https://holochain.love --run "hc scaffold web-app --templates-url https://github.com/holochain-open-dev/templates"`

1b. If you already have an existing project, run this inside a `nix develop` shell:

`hc scaffold template get https://github.com/holochain-open-dev/templates`
