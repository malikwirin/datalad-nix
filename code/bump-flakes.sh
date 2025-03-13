#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash git nix
#!nix-shell --pure

REPO_ROOT=$(git rev-parse --show-toplevel)
EXAMPLES_DIR="${REPO_ROOT}/examples"

bump_flake() {
    local dir=$1
    cd "$dir" || exit 1
    echo "Updating flake in $dir"
    
    nix shell "$REPO_ROOT/#dataladGit" -c datalad run \
        -m "Bump Flake" \
        --input flake.lock --input flake.nix \
        --output flake.lock \
        "nix flake update"
        
    return $?
}

bump_flake "$REPO_ROOT"
MAIN_RESULT=$?

if [ $MAIN_RESULT -eq 0 ] && [ -d "$EXAMPLES_DIR" ]; then
    bump_flake "$EXAMPLES_DIR"
fi
