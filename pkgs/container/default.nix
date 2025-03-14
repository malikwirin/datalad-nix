{ fetchFromGitHub, lib, python3, git, datalad, containerSrc, dataladGit }:

let
  srcBase = version: hash: fetchFromGitHub {
    owner = "datalad";
    repo = "datalad-container";
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
      hash = "sha256-ueqVyCSnEkJBb21X+EM2OC6fJ1/t0YXcaES0CT4/npI=";
    in
    base version (srcBase version hash) datalad "https://github.com/datalad/datalad-container/blob/${version}/CHANGELOG.md";

  gitVersion = base "git" containerSrc dataladGit "";
}
