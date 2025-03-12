{
  description = "Datalad-Nix";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    datalad = {
      url = "github:datalad/datalad";
      flake = false;
    };

    datalad-container = {
      url = "github:datalad/datalad-container";
      flake = false;
    };
  };

  outputs = { self, nixpkgs-unstable, flake-utils, treefmt-nix, datalad, datalad-container }:
    let
      contributors = import ./contributors.nix {
        nixMaintainers = nixpkgs-unstable.lib.maintainers;
      };
      packagesImport = { pkgs, lib }:
        import ./pkgs/default.nix {
          inherit pkgs lib contributors;
          sources = {
            inherit datalad datalad-container;
          };
          flake = import ./flake.nix;
        };
    in
    {
      overlays = rec {
        default = datalad;

        datalad = import ./overlay/default.nix {
          inherit packagesImport contributors;
        };
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs-unstable.legacyPackages.${system};
        lib = pkgs.lib;

        treefmt = treefmt-nix.lib.evalModule pkgs (import ./treefmt.nix);

        mkPackageCheck = name: pkg:
          # skip certain packages
          if (builtins.elem name [ "utils" "with-extensions" ])
          then {}
          else if (lib.isDerivation pkg)
          then {
            # If it's a regular derivation, include it directly
            ${name} = pkg;
          }
          else if (pkg ? default && lib.isDerivation pkg.default)
          then {
            # If it has a default attribute that's a derivation, include that
            "${name}-default" = pkg.default;
          }
          else {};
      in
      rec {
        packages = packagesImport {
          inherit pkgs lib;
        };

        formatter = treefmt.config.build.wrapper;

        checks = {
          formatting = treefmt.config.build.check self;
        } // (lib.concatMapAttrs mkPackageCheck packages);
      });
}
