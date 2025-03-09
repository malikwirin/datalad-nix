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
    datalad-container = packages.container;
    dataladFull = packages.full.default;
    dataladGit = packages.dataladGit;
    dataladGitFull = packages.full.gitVersion;
  }
