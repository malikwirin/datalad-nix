{ nixpkgs, stateVersion, lib, treefmt, self, home-manager, packages, pkgs }:

let
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

  module-tests = import ./test-modules.nix {
    inherit nixpkgs stateVersion home-manager pkgs;
    modules = self.modules;
  };
in
{
  formatting = treefmt.config.build.check self;
} // (lib.concatMapAttrs mkPackageCheck packages) // module-tests
