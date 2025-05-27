{ fetchgit, lib, python3, git, datalad, containerSrc, dataladGit }:

let
  srcBase = version: hash:
    let
      owner = "datalad";
      repo = "datalad-container";
    in
    fetchgit {
      url = "https://github.com/${owner}/${repo}.git";
      rev = version;
      hash = hash;
    };
  base = version: src: dlImpl: changelog: import ./base.nix {
    inherit version src changelog lib git;
    buildPythonApplication = python3.pkgs.buildPythonApplication;
    setuptools = python3.pkgs.setuptools;
    tomli = python3.pkgs.tomli;
    wheel = python3.pkgs.wheel;
    requests = python3.pkgs.requests;
    datalad = dlImpl;
  };
in
rec {
  default = latest;

  latest = v1_2_5;

  v1_2_5 =
    let
      version = "1.2.5";
      hash = "sha256-ZnuLmL0NCtDv5v5plq988al2qQowTn5P/4HDkvZ4pFc=";
    in
    base version (srcBase version hash) datalad "https://github.com/datalad/datalad-container/blob/${version}/CHANGELOG.md";

  gitVersion = base "git" containerSrc dataladGit "";
}
