{
  description = "Datalad-Nix example flake";

  inputs = {
    datalad-nix = {
      url = "path:../";
    };

    nixpkgs.follows = "datalad-nix/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, datalad-nix, ... }:
    let
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      darwinSystems = [ "x86_64-darwin" "aarch64-darwin" ];
      allSystems = linuxSystems ++ darwinSystems;
      stateVersion = builtins.substring 0 5 nixpkgs.lib.version;


      nixpkgsfor = system:
        nixpkgs.legacyPackages.${system};

      mkHomeConfig = system: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgsfor system;
        extraSpecialArgs = {
          inherit datalad-nix system;
        };
        modules = [
          datalad-nix.modules.default
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
    in
    rec {
      nixosConfigurations = import ./nixosConfigurations.nix {
        inherit nixpkgs stateVersion;
        inherit (datalad-nix) modules;
      };

      homeConfigurations = nixpkgs.lib.genAttrs
        allSystems
        (system: mkHomeConfig system);

      packages = nixpkgs.lib.genAttrs allSystems (system:
        let
          packages = {
            "home-module" = (mkHomeConfig system).activationPackage;
          };

          linuxPackages =
            if builtins.elem system linuxSystems
            then { "nixos-module" = nixosConfigurations."system".config.system.build.toplevel; }
            else { };
        in
        packages // linuxPackages
      );
    };
}
