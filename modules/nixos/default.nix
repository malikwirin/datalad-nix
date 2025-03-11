{ pkgs, lib, overlay, config }:

let
  common = import ../common/default.nix { inherit pkgs lib overlay config; };
in
{
  options.programs.datalad = common.options;
  config = common.config {
    environment.systemPackages = [ common.dataladPackage ];
  };
}
