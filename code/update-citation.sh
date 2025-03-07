#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash git nix
#!nix-shell --pure

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"
NIX_SHELL_CMD="nix shell ./#dataladGit -c"


$NIX_SHELL_CMD datalad run -m "Update CITATION.cff" \
  --input flake.lock --input flake.nix --input ./pkgs/default.nix --input ./pkgs/utils.nix --input ./pkgs/citation-creator/default.nix --input ./pkgs/citation-creator/generator.dhall \
  --output CITATION.cff \
  "nix run .#utils.citation-creator"
