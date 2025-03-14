{ nixpkgs, stateVersion, modules, home-manager, system }:

let
  linuxSystems = [ "x86_64-linux" "aarch64-linux" ];

  nixosConfigs = import ../examples/nixosConfigurations.nix {
    inherit nixpkgs stateVersion modules;
  };

  homeConfigs = import ../examples/homeConfigurations.nix {
    inherit nixpkgs home-manager modules stateVersion;
  };

  isLinuxSystem = builtins.elem system linuxSystems;

  hasNixosConfig = isLinuxSystem && nixosConfigs ? ${system};
  hasHomeConfig = homeConfigs ? ${system};

  nixosChecks =
    if hasNixosConfig
    then { "nixos-${system}" = nixosConfigs.${system}.config.system.build.toplevel; }
    else { };

  homeChecks =
    if hasHomeConfig
    then { "home-${system}" = homeConfigs.${system}.activationPackage; }
    else { };

in
nixosChecks // homeChecks
