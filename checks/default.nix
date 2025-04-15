{ nixpkgs, stateVersion, lib, treefmt, self, home-manager, system, packages }:

let
  mkPackageCheck = name: pkg:
    let
      isBroken =
        if (lib.isDerivation pkg && pkg ? meta && pkg.meta ? broken)
        then pkg.meta.broken
        else if (pkg ? default && lib.isDerivation pkg.default && pkg.default ? meta && pkg.default.meta ? broken)
        then pkg.default.meta.broken
        else false;
    in
    # skip certain packages
    if (builtins.elem name [ "utils" "with-extensions" ] || isBroken)
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
    inherit nixpkgs stateVersion home-manager system;
    inherit (self) modules overlays;
  };
in
{
  formatting = treefmt.config.build.check self;
} // (lib.concatMapAttrs mkPackageCheck packages) // module-tests
