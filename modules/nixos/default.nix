{ pkgs, lib, overlay, config, ... }@args:

let
  specificCfg = dataladPackage: {
    environment.systemPackages = [ dataladPackage ];
  };
in
import ../common/default.nix (args // { inherit pkgs lib overlay config specificCfg; })
