{
  projectRootFile = "flake.nix";

  programs = {
    nixpkgs-fmt.enable = true;

    # prettier.enable = true;  # für JS, Markdown, JSON, etc.
    # shfmt.enable = true;     # für Shell-Skripte
    # black.enable = true;     # für Python
    # rustfmt.enable = true;   # für Rust
  };
}
