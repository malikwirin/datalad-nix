{ config, lib, pkgs, overlay, ... }:

let
  isHomeManager = lib.hasAttrByPath [ "home" "username" ] config;

  moduleFile =
    if isHomeManager
    then ./home-manager/default.nix
    else ./nixos/default.nix;

  module = import moduleFile {
    inherit config lib pkgs overlay;
  };
in
module
