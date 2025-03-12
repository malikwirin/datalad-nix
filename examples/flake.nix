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

      mkNixosConfig = system: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          {
            system.stateVersion = stateVersion;
            boot.isContainer = true;

            nixpkgs.hostPlatform = system;

            users.users.example = {
              isNormalUser = true;
            };

            networking.hostName = "example";
          }
          datalad-nix.modules.nixos
          {
            programs.datalad = {
              enable = true;
              unstable = false;
              extensions.datalad-container.enable = true;
            };
          }
        ];
      };

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
    {
      nixosConfigurations = {
        "x86_64" = mkNixosConfig "x86_64-linux";
        "aarch64" = mkNixosConfig "aarch64-linux";
      };

      homeConfigurations = nixpkgs.lib.genAttrs
        allSystems
        (system: mkHomeConfig system);
    };
}
