{
  description = "Datalad-Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
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

  outputs = { self, nixpkgs, flake-utils, treefmt-nix, datalad, datalad-container }:
    {
      overlays = rec {
        default = datalad;

        datalad = final: prev:
          let
            packages = import ./pkgs/default.nix {
              pkgs = final;
              # Adding the maintainer is no longer needed in next release of nixpkgs
              lib = prev.lib // {
                maintainers = prev.lib.maintainers // {
                  malik = {
                    name = "Malik";
                  };
                };
              };
              sources = {
                inherit datalad datalad-container;
              };
            };
          in
          {
            datalad-container = packages.container;
            dataladFull = packages.full;
            dataladGit = packages.dataladGit;
          };
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        treefmt = treefmt-nix.lib.evalModule pkgs (import ./treefmt.nix);
      in
      {
        packages = import ./pkgs/default.nix {
          inherit pkgs lib;
          sources = [
            datalad
            datalad-container
          ];
        };

        formatter = treefmt.config.build.wrapper;

        checks = {
          formatting = treefmt.config.build.check self;
        };
      });
}
