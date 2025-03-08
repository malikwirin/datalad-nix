{ pkgs, lib, sources, flake, contributors }:

let
  inherit (pkgs) fetchFromGitHub git python3;
in
  rec {
  default = pkgs.datalad;

  dataladGit = default.overrideAttrs (oldAttrs: {
    version = "git";

    src = sources.datalad;
    
    propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ pkgs.git-annex ];

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

  with-extensions = import ./with-extensions {
    inherit lib;
    datalad = default;
    dataladGit = dataladGit;
    extensions = [ container.default ];
    extensionsGit = [ container.gitVersion ];
  };

  full = {
    default = with-extensions.default;
    gitVersion = with-extensions.gitVersion;
  };

  utils = import ./utils.nix {
    inherit lib pkgs flake contributors;
  };
}
