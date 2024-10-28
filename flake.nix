{
  description = "Template for Holochain app development";

  inputs = {
    holonix.url = "github:holochain/holonix/main-0.3";
    nixpkgs.follows = "holonix/nixpkgs";
    flake-parts.follows = "holonix/flake-parts";
    scaffolding.url = "github:holochain/scaffolding/holochain-0.3";
  };

  nixConfig = {
    extra-substituters = [ "https://holochain-open-dev.cachix.org" ];
    extra-trusted-public-keys = [
      "holochain-open-dev.cachix.org-1:3Tr+9in6uo44Ga7qiuRIfOTFXog+2+YbyhwI/Z6Cp4U="
    ];
  };

  outputs = inputs@{ flake-parts, holonix, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = builtins.attrNames holonix.devShells;
      perSystem = { config, pkgs, system, inputs', ... }: {
        devShells.default = pkgs.mkShell {
          inputsFrom = [ holonix.devShells.${system}.default ];

          packages = with pkgs; [ nodejs_20 ];
        };

        packages.hc-scaffold-app-template =
          inputs.scaffolding.lib.wrapCustomTemplate {
            inherit pkgs system;
            customTemplatePath = ./templates/app;
          };

        packages.hc-scaffold-zome-template =
          inputs.scaffolding.lib.wrapCustomTemplate {
            inherit pkgs system;
            customTemplatePath = ./templates/zome;
          };
      };
    };
}
