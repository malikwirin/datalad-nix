{ pkgs, lib }:

let
  inherit (pkgs) fetchFromGitHub git python3;
in
rec {
  default = pkgs.datalad;

  container = import ./container {
    inherit lib fetchFromGitHub python3 git;
    datalad = default;
  };

  full = import ./full {
    inherit lib;
    datalad = default;
    extensions = [ container ];
  };
}
