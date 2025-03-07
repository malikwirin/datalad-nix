{ contributors, flake, lib, pkgs }:

{
  citation-creator = import ./citation-creator/default.nix {
    authors = builtins.attrValues contributors;
    title = flake.description;
    version = "git";
    inherit lib;
    writeShellScriptBin = pkgs.writeShellScriptBin;
    cffconvert = pkgs.cffconvert;
    dhall = pkgs.dhall;
    dhall-yaml = pkgs.dhall-yaml;
    gnused = pkgs.gnused;
  };
}
