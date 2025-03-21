{ home-manager, nixpkgs, modules, stateVersion }:

let
  mkHomeConfig = system: home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.${system};
    modules = [
      modules.homeManager
      {
        home = rec {
          inherit stateVersion;
          username = "example";
          homeDirectory =
            if builtins.match ".*darwin" system != null
            then "/Users/${username}"
            else "/home/${username}";
        };

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
