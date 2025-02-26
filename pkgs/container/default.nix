{
  lib,
  python3,
  fetchFromGitHub,
  datalad,
  git,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "datalad-container";
  version = "1.2.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "datalad";
    repo = "datalad-container";
    rev = version;
    hash = "sha256-ueqVyCSnEkJBb21X+EM2OC6fJ1/t0YXcaES0CT4/npI=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.tomli
    python3.pkgs.wheel
  ];

  nativeBuildInputs = [
    git
  ];

  buildInputs = [
    datalad
  ];

  propagatedBuildInputs = [
    python3.pkgs.requests
  ];

  pythonImportsCheck = [
    "datalad_container"
  ];

  meta = {
    description = "DataLad extension for containerized environments";
    homepage = "https://github.com/datalad/datalad-container";
    changelog = "https://github.com/datalad/datalad-container/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ malik ];
    mainProgram = "datalad-container";
  };
}
