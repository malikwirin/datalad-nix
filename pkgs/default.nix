{ pkgs, lib }:

let
  inherit (pkgs) fetchFromGitHub git python3;
in rec {
  default = pkgs.datalad;

  container = import ./container {
    inherit lib fetchFromGitHub python3 git;
    datalad = default;
  };

  with-extensions = import ./with-extensions {
    inherit lib;
    datalad = default;
    extensions = [ container ];
  };
}
