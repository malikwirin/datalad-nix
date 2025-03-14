{ pkgs, lib, overlay, config, ... }@args:

let
specificCfg = dataladPackage: {
  home.packages = [ dataladPackage ];
};
in
import ../common/default.nix (args // { inherit pkgs lib overlay config specificCfg; })
