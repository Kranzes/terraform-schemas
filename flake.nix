{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts = { url = "github:hercules-ci/flake-parts"; inputs.nixpkgs-lib.follows = "nixpkgs"; };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem = { pkgs, lib, config, ... }:
        let
          terraformProviders = pkgs.terraform-providers.actualProviders;
        in
        {
          legacyPackages.generateSchema = providerFn: pkgs.callPackage (import ./generator.nix (providerFn terraformProviders)) { };

          packages = builtins.mapAttrs (name: p: config.legacyPackages.generateSchema (_: { ${name} = p; })) terraformProviders // {
            all-schemas = config.legacyPackages.generateSchema (p: lib.genAttrs (builtins.attrNames terraformProviders) (name: p.${name}));
          };
        };
    };
}
