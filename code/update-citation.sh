#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash git nix
#!nix-shell --pure

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"
NIX_SHELL_CMD="nix shell ./#dataladGit -c"


$NIX_SHELL_CMD datalad --version

