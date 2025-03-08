{ lib, datalad, extensions, dataladGit, extensionsGit }:

let
  # Extracting all maintainers from extensions
  extensionsMaintainers = maintainers: lib.flatten (
    map (ext: ext.meta.maintainers or [ ]) extensions
  );

  withExtensionBase = programeName: extensions: datalad: datalad.overrideAttrs (oldAttrs: {
    pname = programeName;

    propagatedBuildInputs = (oldAttrs.propagatedBuildInputs or [ ]) ++ extensions;

    meta = oldAttrs.meta // {
      maintainers = lib.unique (
        with lib.maintainers; [ malik ] ++
          (oldAttrs.meta.maintainers or [ ]) ++
          extensionsMaintainers maintainers
      );
    };
  });
in
{
  default = withExtensionBase "dataladFull" [ extensions ] datalad;

  gitVersion = withExtensionBase "dataladGitFull" [ extensionsGit ] dataladGit;
}
