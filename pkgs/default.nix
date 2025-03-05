{ pkgs, lib, dataladSrc }:

let
  inherit (pkgs) fetchFromGitHub git python3;
in
rec {
  default = pkgs.datalad;

  dataladGit = default.overrideAttrs (oldAttrs: {
    version = "git";

    src = dataladSrc;

    meta = oldAttrs.meta // {
      homepage = "https://github.com/datalad/datalad";
      maintainers = lib.unique (
        with lib.maintainers; [ malik ] ++
          (oldAttrs.meta.maintainers or [ ])
      );
    };
  });

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
