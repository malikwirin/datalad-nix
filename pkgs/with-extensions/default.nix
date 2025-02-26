{ lib, datalad, extensions }:

datalad.overrideAttrs (oldAttrs: {
  pname = "datalad-with-extensions";
  
  propagatedBuildInputs = (oldAttrs.propagatedBuildInputs or []) ++ extensions;

  meta = oldAttrs.meta // {
    description = "DataLad with dependencies";
    maintainers = with lib.maintainers; [ malik ] ++ (oldAttrs.meta.maintainers or []);
  };
})
