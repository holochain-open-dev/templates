{
  description = "Template for Holochain app development";

  inputs = {
    holochain = {
      url = "github:holochain/holochain";
      inputs.versions.url = "github:holochain/holochain?dir=versions/weekly";
    };

    nixpkgs.follows = "holochain/nixpkgs";
    flake-parts.follows = "holochain/flake-parts";
    scaffolding.url = "github:holochain/scaffolding/update-holochain-source";
  };

  nixConfig = {
		extra-substituters = [
	    "https://holochain-open-dev.cachix.org"
	  ];	
		extra-trusted-public-keys = [
			"holochain-open-dev.cachix.org-1:3Tr+9in6uo44Ga7qiuRIfOTFXog+2+YbyhwI/Z6Cp4U="
	  ];
	};

  outputs = inputs @ { flake-parts, holochain, ... }:
    flake-parts.lib.mkFlake
      {
        inherit inputs;
      }
      {
        systems = builtins.attrNames holochain.devShells;
        perSystem =
          { config
          , pkgs
          , system
          , inputs'
          , ...
          }: {
            devShells.default = pkgs.mkShell {
              inputsFrom = [ holochain.devShells.${system}.holonix ];

              packages = with pkgs; [
                nodejs_20
              ];
            };

            packages.hc-scaffold-app-template = inputs.scaffolding.lib.wrapCustomTemplate {
              inherit pkgs system;
              customTemplatePath = ./templates/app;
            };

            packages.hc-scaffold-module-template = inputs.scaffolding.lib.wrapCustomTemplate {
              inherit pkgs system;
              customTemplatePath = ./templates/module;
            };

          };
      };
}
