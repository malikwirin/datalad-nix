{ packagesImport, contributors }:

final: prev:
let
  packages = packagesImport {
    pkgs = final;
    # Adding the maintainer is no longer needed in next release of nixpkgs
    lib = prev.lib // {
      maintainers = prev.lib.maintainers // contributors;
    };
  };
in
{
  inherit (packages) dataladGit forgejo-aneksajo;

  datalad-container = packages.container.default;
  datalad-containerGit = packages.container.gitVersion;

  dataladFull = packages.full.default;
  dataladGitFull = packages.full.gitVersion;

  dataladWithExtensions = packages.with-extensions;
}
