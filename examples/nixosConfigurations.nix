{ nixpkgs, stateVersion, modules, overlays }:
let
  mkNixosConfig = system: nixpkgs.lib.nixosSystem {
    inherit system;
    modules = let
      pkgs = import nixpkgs { inherit system; };
    in [
      {
        system.stateVersion = stateVersion;
        boot.isContainer = true;

        nixpkgs = {
          overlays = [
            overlays.default
          ];
          hostPlatform = system;
        };

        users.users.example = {
          isNormalUser = true;
        };

        networking.hostName = "example";
      }
      modules.default
      {
        programs.datalad = {
          enable = true;
          unstable = false;
          extensions.datalad-container.enable = true;
        };

        services.forgejo.package = pkgs.forgejo-aneksajo;
      }
    ];
  };
in
{
  "x86_64-linux" = mkNixosConfig "x86_64-linux";
  "aarch64-linux" = mkNixosConfig "aarch64-linux";
}
