{ lib, datalad, extensions }:

datalad.overrideAttrs (oldAttrs: {
  pname = "dataladFull";
  
  propagatedBuildInputs = (oldAttrs.propagatedBuildInputs or []) ++ extensions;

  meta = oldAttrs.meta // {
    maintainers = with lib.maintainers; [ malik ] ++ (oldAttrs.meta.maintainers or []);
  };
})
