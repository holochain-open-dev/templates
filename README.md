# Holochain Open Dev Templates

Custom templates for the [scaffolding tool](https://github.com/holochain/scaffolding), to develop apps and modules using the holochain-open-dev style!

There are two templates available:

- `app`: fully blown app, following the open-dev patterns and with the profiles module pre-installed.
- `module`: template to build modules like the ones you can find in [open-dev](https://github.com/holochain-open-dev), with the profiles module already pre-installed.

## Using the templates

> WARNING: these templates are only compatible with holochain v0.3.x.

1a. To scaffold a new **app** project, run this:

`nix run github:holochain-open-dev/templates#hc-scaffold-app-template -- web-app`

1b. To scaffold a new **module** project, run this:

`nix run github:holochain-open-dev/templates#hc-scaffold-module-template -- web-app`

2. If you already have an existing project, add the `holochain-open-dev/templates` repository as input to your flake, and use it in the packages or your `devShell`:

```diff
{
  description = "Template for Holochain app development";

  inputs = {
    versions.url  = "github:holochain/holochain?dir=versions/weekly";

    holochain-flake.url = "github:holochain/holochain";
    holochain-flake.inputs.versions.follows = "versions";

    nixpkgs.follows = "holochain-flake/nixpkgs";
    flake-parts.follows = "holochain-flake/flake-parts";

+   scaffolding.url = "github:holochain-open-dev/templates";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake
      {
        inherit inputs;
      }
      {
        systems = builtins.attrNames inputs.holochain-flake.devShells;
        perSystem =
          { inputs'
          , config
          , pkgs
          , system
          , ...
          }: {
            devShells.default = pkgs.mkShell {
              inputsFrom = [ inputs'.holochain-flake.devShells.holonix ];
              packages = [
                pkgs.nodejs_20
                # more packages go here
+             ] ++ [
+                # inputs'.scaffolding.packages.hc-scaffold-module-template # if your repository is a module
+                inputs'.scaffolding.packages.hc-scaffold-app-template      # if your repository is an app
              ];
            };
          };
      };
}  
```

---

After this set up, you will be able to `nix develop` from inside your repository, and use the scaffolding tool as normal:

```
hc scaffold dna
hc scaffold zome
...
```

And all the `hc scaffold` commands will already be using this custom template.
