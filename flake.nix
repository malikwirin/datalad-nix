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

        datalad = final: prev:
          let
            packages = packagesImport {
              pkgs = final;
              # Adding the maintainer is no longer needed in next release of nixpkgs
              lib = prev.lib // {
                maintainers = prev.lib.maintainers // contributors;
              };
            };
          in
          {
            datalad-container = packages.container;
            dataladFull = packages.full.default;
            dataladGit = packages.dataladGit;
            dataladGitFull = packages.full.gitVersion;
          };
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs-unstable.legacyPackages.${system};
        lib = pkgs.lib;

        treefmt = treefmt-nix.lib.evalModule pkgs (import ./treefmt.nix);
      in
      {
        packages = packagesImport {
          inherit pkgs lib;
        };

        formatter = treefmt.config.build.wrapper;

        checks = {
          formatting = treefmt.config.build.check self;
        };
      });
}
