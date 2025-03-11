{ pkgs, lib, overlay, config }:

let
  cfg = config.programs.datalad;
  common = import ../common/default.nix { inherit pkgs lib overlay cfg; };
in
{
  options.programs.datalad = common.options;
  config = lib.mkIf cfg.enable 
    {
      environment.systemPackages = [ common.dataladPackage ];
    } // common.config;
}
