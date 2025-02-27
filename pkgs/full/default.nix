{ lib, datalad, extensions }:

let
  # Extracting all maintainers from extensions
  extensionsMaintainers = lib.flatten (
    map (ext: ext.meta.maintainers or []) extensions
  );
in
datalad.overrideAttrs (oldAttrs: {
  pname = "dataladFull";
  
  propagatedBuildInputs = (oldAttrs.propagatedBuildInputs or []) ++ extensions;

  meta = oldAttrs.meta // {
    maintainers = lib.unique (
      with lib.maintainers; [ malik ] ++
      (oldAttrs.meta.maintainers or []) ++
      extensionsMaintainers
    );
  };
})
