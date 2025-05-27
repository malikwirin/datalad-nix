{ packagesImport }:

final: prev:
let
  packages = packagesImport {
    pkgs = final;
    lib = final.lib;
  };
in
{
  dataladGit = packages.dataladGit;

  datalad-container = packages.container.default;
  datalad-containerGit = packages.container.gitVersion;

  dataladFull = packages.full.default;
  dataladGitFull = packages.full.gitVersion;

  dataladWithExtensions = packages.with-extensions;
}
