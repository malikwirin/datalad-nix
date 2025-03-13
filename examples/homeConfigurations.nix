{ home-manager, nixpkgs, modules }:

let
  mkHomeConfig = system: home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.${system};
    modules = [
      modules.default
      {
        programs.datalad = {
          enable = true;
          unstable = true;
          extensions.datalad-container = {
            enable = true;
          };
        };
      }
    ];
  };

  allSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
in
nixpkgs.lib.genAttrs
  allSystems
  (system: mkHomeConfig system)
