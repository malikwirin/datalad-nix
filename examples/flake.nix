{
  description = "Datalad-Nix example flake";

  inputs = {
    datalad-nix = {
      url = "path:../";
    };

    nixpkgs.follows = "datalad-nix/nixpkgs-unstable";

    home-manager.follows = "datalad-nix/home-manager";
  };

  outputs = { nixpkgs, home-manager, datalad-nix, ... }:
    let
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      darwinSystems = [ "x86_64-darwin" "aarch64-darwin" ];
      allSystems = linuxSystems ++ darwinSystems;
      stateVersion = builtins.substring 0 5 nixpkgs.lib.version;
    in
    rec {
      nixosConfigurations = import ./nixosConfigurations.nix {
        inherit nixpkgs stateVersion;
        inherit (datalad-nix) modules;
      };

      homeConfigurations = import ./homeConfigurations.nix {
        inherit nixpkgs home-manager;
        inherit (datalad-nix) modules;
      };

      packages = nixpkgs.lib.genAttrs allSystems (system:
        let
          packages = {
            "home-module" = homeConfigurations."${system}".activationPackage;
          };

          linuxPackages =
            if builtins.elem system linuxSystems
            then { "nixos-module" = nixosConfigurations."{system}".config.system.build.toplevel; }
            else { };
        in
        packages // linuxPackages
      );
    };
}
