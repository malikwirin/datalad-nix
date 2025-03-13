{
  description = "Datalad-Nix";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

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

    nix-github-actions = {
      url = "github:nix-community/nix-github-actions";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs-unstable, flake-utils, treefmt-nix, datalad, datalad-container, nix-github-actions, home-manager }:
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

      githubActions = nix-github-actions.lib.mkGithubMatrix { inherit (self) checks; };

      modules =
        let
          importModule = path: { config, lib, pkgs, ... }@args:
            import path ({
              inherit config lib pkgs;
              overlay = self.overlays.datalad;
            } // args);
        in
        {
          default = importModule ./modules/default.nix;

          nixos = importModule ./modules/nixos/default.nix;
          homeManager = importModule ./modules/home-manager/default.nix;
        };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs-unstable.legacyPackages.${system};
        lib = pkgs.lib;
        treefmt = treefmt-nix.lib.evalModule pkgs (import ./treefmt.nix);
      in
      rec {
        packages = packagesImport {
          inherit pkgs lib;
        };

        formatter = treefmt.config.build.wrapper;

        checks = import ./checks.nix {
          inherit lib treefmt self packages;
        };
      });
}
