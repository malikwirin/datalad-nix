{ nixpkgs, stateVersion, modules, home-manager, pkgs }:

let
  moduleWorks = system:
    let
      result = builtins.tryEval (
        let
          nixosConfig = import ../examples/nixosConfigurations.nix {
            inherit nixpkgs stateVersion modules;
          };
          
          homeConfig = import ./examples/homeConfigurations.nix {
            inherit home-manager nixpkgs modules;
          };
          
          nixosTest = nixosConfig."${system}";
          homeTest = homeConfig."${system}";
        in
        true
      );
    in
    result.success;
    
  mkSystemTest = system: {
    name = "test-modules-${system}";
    value = pkgs.runCommand "test-modules-${system}" {} ''
      if [[ "${toString (moduleWorks system)}" == "true" ]]; then
        echo "Module test for ${system} passed" > $out
      else
        echo "Module test for ${system} failed"
        exit 1
      fi
    '';
  };
  
  systemTests = builtins.listToAttrs (map mkSystemTest [
    "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"
  ]);
in
systemTests
