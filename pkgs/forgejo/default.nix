{ default, lib, pkgs }:

let
  base = import ./base.nix {
    inherit default lib;
    inherit (pkgs) buildNpmPackage bash git gzip openssh;
  };
  stableBase = { rev, hash, npmDepsHash, vendorHash }: base {
    src = pkgs.fetchFromGitea {
      domain = "codeberg.org";
      owner = "forgejo-aneksajo";
      repo = "forgejo-aneksajo";
      inherit rev hash;
    };

    version = rev;
    inherit vendorHash npmDepsHash;
  };
in
{
  inherit default;

  aneksajo = rec {
    default = stable;

    stable = v10_0_3;

    v10_0_3 = stableBase {
      rev = "v10.0.3-git-annex0";
      hash = "sha256-FIIO8sf58j/J/RU0W2RUBjqN5dWWdUFkXaQ1dDcWxFU=";
      npmDepsHash = "sha256-EilG3wNu5153xRXiIhgQaxe3sh1TnSlMPQPUhqSh9mM=";
      vendorHash = "sha256-b3+zxsKRylgfdW0Yiz0QryObMKdtiMCt0hB3DtAGFrQ=";
    };
  };
}
