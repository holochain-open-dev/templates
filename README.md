# Holochain Open Dev Templates

Custom templates for the [scaffolding tool](https://github.com/holochain/scaffolding), to develop apps and modules using the holochain-open-dev style!

There are two templates available:

- `app`: fully blown app, following the open-dev patterns and with the profiles zome pre-installed.
- `zome`: template to build zomes like the ones you can find in [open-dev](https://github.com/holochain-open-dev), with the profiles zome already pre-installed.

## Using the templates

> WARNING: these templates are only compatible with holochain v0.3.x.

0. If you haven't already, set up the holochain-open-dev binary cache:

```bash
nix run nixpkgs#cachix use holochain-open-dev
```

This is necessary to enable fetching of most dependencies from the cache, rather than rebuilding all of them from the scratch.

1a. To scaffold a new **app** project, run this:

```bash
nix run github:holochain-open-dev/templates#hc-scaffold-app-template -- web-app
```

1b. To scaffold a new **zome** project, run this:

```bash
nix run github:holochain-open-dev/templates#hc-scaffold-zome-template -- web-app
```

2. If you already have an existing project, add the `holochain-open-dev/templates` repository as input to your flake, and use it in the packages or your `devShell`:

```diff
{
  description = "Template for Holochain app development";

  inputs = {
    holonix.url = "github:holochain/holonix/main-0.3";
    nixpkgs.follows = "holonix/nixpkgs";
    flake-parts.follows = "holonix/flake-parts";

+   scaffolding.url = "github:holochain-open-dev/templates";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake
      {
        inherit inputs;
      }
      {
        systems = builtins.attrNames inputs.holonix.devShells;
        perSystem =
          { inputs'
          , config
          , pkgs
          , system
          , ...
          }: {
            devShells.default = pkgs.mkShell {
              inputsFrom = [ inputs'.holonix.devShells.default ];
              packages = [
                pkgs.nodejs_20
                # more packages go here
+             ] ++ [
+                # inputs'.scaffolding.packages.hc-scaffold-zome-template # if your repository is a zome
+                inputs'.scaffolding.packages.hc-scaffold-app-template      # if your repository is an app
              ];
            };
          };
      };
}  
```

---

After this set up, you will be able to `nix develop` from inside your repository, and use the scaffolding tool as normal:

```bash
hc scaffold dna
hc scaffold zome
...
```

And all the `hc scaffold` commands will already be using this custom template.
