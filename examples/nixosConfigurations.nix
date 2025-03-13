{ nixpkgs, stateVersion, modules }:
let
  mkNixosConfig = system: nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      {
      system.stateVersion = stateVersion;
      boot.isContainer = true;

      nixpkgs.hostPlatform = system;

      users.users.example = {
        isNormalUser = true;
      };

      networking.hostName = "example";
      }
      modules.nixos
      {
        programs.datalad = {
          enable = true;
          unstable = false;
          extensions.datalad-container.enable = true;
        };
      }
    ];
  };
in
{
  "x86_64" = mkNixosConfig "x86_64-linux";
  "aarch64" = mkNixosConfig "aarch64-linux";
}
