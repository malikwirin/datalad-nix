#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash git nix

REPO_ROOT=$(git rev-parse --show-toplevel)

GENERATE_FORMATTING_SCRIPT="${REPO_ROOT}/code/generate-formatter-check.sh"
GENERATE_EVALUATION_SCRIPT="${REPO_ROOT}/code/generate-eval-checks.sh"

generate() {
    local dir=$1
    cd "$dir" || exit 1
    echo "Run workflow generation"

    echo "Generating formatting workflow..."
    nix shell "$REPO_ROOT/#dataladGit" -c \
      datalad run \
        -m "Generate Formatting Workflow" \
        --input "${GENERATE_FORMATTING_SCRIPT}" \
        --input "${REPO_ROOT}/flake.nix" \
        --output "${REPO_ROOT}/.woodpecker/formatting-check.yml" \
        "${GENERATE_FORMATTING_SCRIPT}"
    
    echo "Generating evaluation workflow..."
    nix shell "$REPO_ROOT/#dataladGit" -c \
      datalad run \
        -m "Generate Evaluation Workflow" \
        --input "${GENERATE_EVALUATION_SCRIPT}" \
        --input "${REPO_ROOT}/flake.nix" \
        --output "${REPO_ROOT}/.woodpecker/eval-checks.yml" \
        "${GENERATE_EVALUATION_SCRIPT}"
    echo "✅ Generation completed"

    return $?
}

mkdir -p "$REPO_ROOT/.woodpecker"
generate "$REPO_ROOT"
