#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash git nix
#!nix-shell --pure

REPO_ROOT=$(git rev-parse --show-toplevel)
nix_shell_cmd () {
  nix shell $REPO_ROOT/#dataladGit -c "$1"
}

cd "$REPO_ROOT"
BUMP_FLAKE='datalad run -m "Bump Flake" \
	--input flake.lock --input flake.nix \
	--output flake.lock \
	"nix flake update"'

nix_shell_cmd $BUMP_FLAKE && cd $REPO_ROOT/exampes && nix_shell_cmd $BUMP_FLAKE
