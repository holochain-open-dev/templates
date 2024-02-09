{
  description = "Template for Holochain app development";

  inputs = {
    holochain-nix-versions.url  = "github:holochain/holochain?dir=versions/0_2";

    holochain-flake = {
      url = "github:holochain/holochain";
      inputs.versions.follows = "holochain-nix-versions";
    };

    nixpkgs.follows = "holochain-flake/nixpkgs";
    flake-parts.follows = "holochain-flake/flake-parts";
  };

  outputs = inputs @ { flake-parts, holochain-flake, ... }:
    flake-parts.lib.mkFlake
      {
        inherit inputs;
      }
      {
        systems = builtins.attrNames holochain-flake.devShells;
        perSystem =
          { config
          , pkgs
          , system
          , ...
          }: {
            devShells.default = pkgs.mkShell {
              inputsFrom = [ holochain-flake.devShells.${system}.holonix ];

              packages = with pkgs; [
                nodejs-18_x
                cargo-nextest
              ];
            };

            packages.hc-scaffold-template-app = pkgs.runCommand "hc-scaffold" {
              buildInputs = [ pkgs.makeWrapper ];
              src = ./.;
            } ''
              mkdir $out
              mkdir $out/.templates
              # Link every top-level folder from pkgs.hello to our new target
              ln -s ${holochain-flake.packages.${system}.hc-scaffold}/* $out
              # Except the bin folder
              rm $out/bin
              mkdir $out/bin
              # We create the bin folder ourselves and link every binary in it
              ln -s ${holochain-flake.packages.${system}.hc-scaffold}/bin/* $out/bin
              # Except the hello binary
              rm $out/bin/hc-scaffold
              cp $src/.templates/app -R $out/.templates
              # Because we create this ourself, by creating a wrapper
              makeWrapper ${holochain-flake.packages.${system}.hc-scaffold}/bin/hc-scaffold $out/bin/hc-scaffold \
                --append-flags "--template app --templates-path $out/.templates"
            '';

            packages.hc-scaffold-template-module= pkgs.runCommand "hc-scaffold" {
              buildInputs = [ pkgs.makeWrapper ];
              src = ./.;
            } ''
              mkdir $out
              mkdir $out/.templates
              # Link every top-level folder from pkgs.hello to our new target
              ln -s ${holochain-flake.packages.${system}.hc-scaffold}/* $out
              # Except the bin folder
              rm $out/bin
              mkdir $out/bin
              # We create the bin folder ourselves and link every binary in it
              ln -s ${holochain-flake.packages.${system}.hc-scaffold}/bin/* $out/bin
              # Except the hello binary
              rm $out/bin/hc-scaffold
              cp $src/.templates/module -R $out/.templates
              # Because we create this ourself, by creating a wrapper
              makeWrapper ${holochain-flake.packages.${system}.hc-scaffold}/bin/hc-scaffold $out/bin/hc-scaffold \
                --append-flags "--template module --templates-path $out/.templates"
            '';

          };
      };
}
