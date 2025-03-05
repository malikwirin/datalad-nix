{ buildPythonApplication 
, lib
, version
, src
, datalad
, setuptools
, tomli
, wheel
, git
, requests
, changelog
}:

buildPythonApplication {
  pname = "datalad-container";
  inherit version src;
  pyproject = true;

  build-system = [
    setuptools
    tomli
    wheel
  ];

  nativeBuildInputs = [
    git
  ];

  buildInputs = [
    datalad
  ];

  propagatedBuildInputs = [
    requests
  ];

  pythonImportsCheck = [
    "datalad_container"
  ];

  meta = {
    description = "DataLad extension for containerized environments";
    homepage = "https://github.com/datalad/datalad-container";
    inherit changelog;
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ malik ];
    mainProgram = "datalad-container";
  };
}
