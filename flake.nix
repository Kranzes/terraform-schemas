{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts = { url = "github:hercules-ci/flake-parts"; inputs.nixpkgs-lib.follows = "nixpkgs"; };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem = { pkgs, config, ... }:
        {
          legacyPackages.generateSchema = pkgs.callPackage ./generator.nix { };

          packages = builtins.mapAttrs (provider: _: config.legacyPackages.generateSchema [ provider ]) pkgs.terraform-providers.actualProviders // {
            all-schemas = config.legacyPackages.generateSchema (builtins.attrNames pkgs.terraform-providers.actualProviders);
          };
        };
    };
}
