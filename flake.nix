{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts = { url = "github:hercules-ci/flake-parts"; inputs.nixpkgs-lib.follows = "nixpkgs"; };
    hercules-ci-effects = { url = "github:hercules-ci/hercules-ci-effects"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } ({ withSystem, config, ... }: {
      systems = [ "x86_64-linux" ];
      imports = [ inputs.hercules-ci-effects.flakeModule ];

      perSystem = { pkgs, config, ... }: {
        legacyPackages.generateSchema = pkgs.callPackage ./generator.nix { };

        packages = builtins.mapAttrs (provider: _: config.legacyPackages.generateSchema [ provider ]) pkgs.terraform-providers.actualProviders // {
          all-schemas = config.legacyPackages.generateSchema (builtins.attrNames pkgs.terraform-providers.actualProviders);
        };
      };

      hercules-ci.flake-update = {
        enable = true;
        autoMergeMethod = "rebase";
        # Update  everynight at midnight
        when = {
          hour = [ 0 ];
          minute = 0;
        };
      };

      herculesCI = herculesCI: {
        onPush.default.outputs.effects.dump-to-branch = withSystem config.defaultEffectSystem ({ pkgs, config, hci-effects, ... }:
          hci-effects.runIf (herculesCI.config.repo.branch == "master") (hci-effects.gitWriteBranch {
            git.checkout.remote.url = herculesCI.config.repo.remoteHttpUrl;
            git.checkout.forgeType = "github";
            git.checkout.user = "x-access-token";
            git.update.branch = "schemas";
            contents = config.packages.all-schemas;
          }));
      };
    });
}
