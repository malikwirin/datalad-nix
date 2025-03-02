{
  description = "Datalad-Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
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
            };
          in {
            datalad-container = packages.container;
            dataladFull = packages.full;
          };
      };
    } // flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
    in {
      packages = import ./pkgs/default.nix { inherit pkgs lib; };
      });
}
