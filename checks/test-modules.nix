{ nixpkgs, stateVersion, lib, modules, home-manager }:

let
  linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
  darwinSystems = [ "x86_64-darwin" "aarch64-darwin" ];
  allSystems = linuxSystems ++ darwinSystems;
  
  nixosConfigs = import ../examples/nixosConfigurations.nix {
    inherit nixpkgs stateVersion modules;
  };
  
  homeConfigs = import ../examples/homeConfigurations.nix {
    inherit nixpkgs home-manager modules;
  };
  
  nixosChecks = lib.genAttrs 
    (builtins.filter (system: nixosConfigs ? ${system}) linuxSystems)
    (system: nixosConfigs.${system}.config.system.build.toplevel);
  
  homeChecks = lib.genAttrs 
    (builtins.filter (system: homeConfigs ? ${system}) allSystems)
    (system: homeConfigs.${system}.activationPackage);
  
  renamedNixosChecks = lib.mapAttrs' 
    (name: value: { name = "nixos-${name}"; value = value; }) 
    nixosChecks;
  
  renamedHomeChecks = lib.mapAttrs' 
    (name: value: { name = "home-${name}"; value = value; }) 
    homeChecks;
in
renamedNixosChecks // renamedHomeChecks
