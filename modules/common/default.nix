{ lib
, pkgs
, config
, overlay
}:

with lib;
let
  cfg = config.programs.datalad;

  extensionNames = [
    "datalad-container"
    # "datalad-metalad"
    # "datalad-next"
  ];

  extensionPkgs = {
    "datalad-container" =
      unstable: if unstable then pkgs.datalad-containerGit else pkgs.datalad-container;
  };

  extensionBase =
    name:
    mkOption {
      default = { };
      description = "${name} extension options";
      type = types.submodule {
        options = {
          enable = mkEnableOption "${name} extension";
          package = mkOption {
            type = types.package;
            default = extensionPkgs.${name} cfg.extensions.${name}.unstable;
            defaultText = literalExpression "extensions.${name} cfg.unstable";
            description = "The ${name} package to use.";
          };
          unstable = mkOption {
            type = types.bool;
            default = cfg.unstable;
            description = "Whether to use the unstable version of the ${name} extension.";
          };
        };
      };
    };

  extensionOptions = listToAttrs (map (name: nameValuePair name (extensionBase name)) extensionNames);

  enabledExtNames = attrNames (filterAttrs (name: extCfg: extCfg.enable or false) cfg.extensions);

  getExtPackage = name: cfg.extensions.${name}.package;
  enabledExtensionsPkgs = map getExtPackage enabledExtNames;
in
{
  options = {
    enable = mkEnableOption "DataLad";

    package = mkOption {
      type = types.package;
      default = if cfg.unstable then pkgs.dataladGit else pkgs.datalad;
      defaultText = literalExpression "pkgs.datalad";

      description = "The DataLad package to use.";
    };

    unstable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to use the unstable versions of DataLad and extensions.";
    };

    extensions = mkOption {
      default = { };
      description = "DataLad extensions.";
      type = types.submodule {
        options = extensionOptions;
      };
    };
  };

  dataladPackage = pkgs.dataladWithExtensions {
    datalad = cfg.package;
    extensions = enabledExtensionsPkgs;
  };

  config = domainConfig: mkIf cfg.enable
    {
      nixpkgs.overlays = [ overlay ];

      programs.git = {
        enable = true;
        # DataLad-specific Git configuration
      };
    } // domainConfig;
}
