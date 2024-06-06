{
  description = "Template for Holochain app development";

  inputs = {
    versions.url = "github:holochain/holochain?dir=versions/0_3_rc";

    holochain.url = "github:holochain/holochain";
    holochain.inputs.versions.follows = "versions";

    nixpkgs.follows = "holochain/nixpkgs";
    flake-parts.follows = "holochain/flake-parts";

    hc-infra = {
      url = "github:holochain-open-dev/infrastructure";
    };
    scaffolding = {
      url = "github:holochain-open-dev/templates";
    };

  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake
      {
        inherit inputs;
      }
      {
        imports = [
          ./happ.nix
        ];
      
        systems = builtins.attrNames inputs.holochain.devShells;
        perSystem =
          { inputs'
          , config
          , pkgs
          , system
          , ...
          }: {
            devShells.default = pkgs.mkShell {
              inputsFrom = [ 
                inputs'.hc-infra.devShells.synchronized-pnpm
                inputs'.holochain.devShells.holonix
              ];
              packages = [
                inputs'.scaffolding.packages.hc-scaffold-app-template
              ];
            };
          };
      };
}
