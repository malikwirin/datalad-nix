{ nixpkgs, stateVersion, lib, treefmt, self, home-manager, packages }:

let
  linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
  darwinSystems = [ "x86_64-darwin" "aarch64-darwin" ];
  allSystems = linuxSystems ++ darwinSystems;

  nixosConfigurations = import ./examples/nixosConfigurations.nix {
    inherit nixpkgs stateVersion;
    inherit (self) modules;
  };

  homeConfigurations = import ./examples/homeConfigurations.nix {
    inherit nixpkgs home-manager;
    inherit (self) modules;
  };

  allPackages = packages // lib.genAttrs allSystems (system:
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

  mkPackageCheck = name: pkg:
    # skip certain packages
    if (builtins.elem name [ "utils" "with-extensions" ])
    then { }
    else if (lib.isDerivation pkg)
    then {
      # If it's a regular derivation, include it directly
      ${name} = pkg;
    }
    else if (pkg ? default && lib.isDerivation pkg.default)
    then {
      # If it has a default attribute that's a derivation, include that
      "${name}-default" = pkg.default;
    }
    else { };
in
{
  formatting = treefmt.config.build.check self;
} // (lib.concatMapAttrs mkPackageCheck allPackages)
