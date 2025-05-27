{ pkgs, lib, sources, flake }:

let
  inherit (pkgs) fetchFromGitHub git python3;
in
rec {
  default = pkgs.datalad;

  dataladGit = default.overrideAttrs (oldAttrs:
    let
      version = "1.2.1.dev0+g${builtins.substring 0 7 sources.datalad.rev}";
    in
    {
      inherit version;

      src = sources.datalad;

      patches = [
        ./patches/fix-ls-path.patch
      ] ++ (oldAttrs.patches or [ ]);

      propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ pkgs.git-annex ];

      postPatch = ''
        sed -i '/def get_versions/,/^$/c\def get_versions():\n    return {"version": "${version}", "full-revisionid": None, "dirty": None, "error": None, "date": None}\n' datalad/_version.py
      '';

      disabledTests = [
        "test__version__"
      ] ++ (oldAttrs.disabledTests or [ ]);

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

  with-extensions = { datalad, extensions }: import ./with-extensions {
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
    inherit lib pkgs flake;
  };
}
