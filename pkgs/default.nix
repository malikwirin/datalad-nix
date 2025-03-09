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

  with-extensions = {datalad, extensions }: import ./with-extensions {
    inherit lib datalad extensions;
  };

  full =
    let
      allExtensions = [ container.default ];
      allExtensionsGit = [ container.gitVersion ];
    in
    {
      default = with-extensions {
        datalad = default;
        extensions = allExtensions;
      };
      gitVersion = with-extensions {
        datalad = dataladGit;
        extensions = allExtensionsGit;
      };
  };

  utils = import ./utils.nix {
    inherit lib pkgs flake contributors;
  };
}
