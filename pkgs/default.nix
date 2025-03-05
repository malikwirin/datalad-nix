{ pkgs, lib, sources }:

let
  inherit (pkgs) fetchFromGitHub git python3;
in
rec {
  default = pkgs.datalad;

  dataladGit = default.overrideAttrs (oldAttrs: {
    version = "git";

    src = sources.datalad;

    meta = oldAttrs.meta // {
      homepage = "https://github.com/datalad/datalad";
      maintainers = lib.unique (
        with lib.maintainers; [ malik ] ++
          (oldAttrs.meta.maintainers or [ ])
      );
      changelog = "";
    };
  });

  container = import ./container {
    inherit fetchFromGitHub lib python3 git dataladGit;
    datalad = default;
    containerSrc = sources.datalad-container;
  };

  full = import ./full {
    inherit lib;
    datalad = default;
    extensions = [ container.default ];
  };
}
