{ default, lib, buildNpmPackage, bash, git, gzip, openssh }:

{ src, version, npmDepsHash }:
let
  # frontend might be available through oldAttrs.passthru.frontend but npmDespsHash might be different when src is overwritten
  frontend = buildNpmPackage {
    pname = "forgejo-frontend";
    inherit src version npmDepsHash;

    patches = [
      ./patches/package-json-npm-build-frontend.patch
    ];

    # override npmInstallHook
    installPhase = ''
      mkdir $out
      cp -R ./public $out/
    '';
  };

  homepage = "https://codeberg.org/forgejo-aneksajo/forgejo-aneksajo";
in
default.overrideAttrs (oldAttrs:
let
  inherit (oldAttrs) tags;
in
{
  pname = "forgejo-aneksajo";
  inherit src version tags;
  inherit (oldAttrs)
    subPackages
    outputs
    nativeBuildInputs
    nativeCheckInputs
    patches
    postPatch
    preCheck
    checkFlags
    vendorHash
    # seems to be missing overrideModAttrs
    ;

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
    "-X 'main.Tags=${lib.concatStringsSep " " tags}'"
  ];

  preConfigure = ''
    export ldflags+=" -X main.ForgejoVersion=$(GITEA_VERSION=${version} make show-version-api)"
  '';

  postInstall = ''
    mkdir $data
    cp -R ./{templates,options} ${frontend}/public $data
    mkdir -p $out
    cp -R ./options/locale $out/locale
    wrapProgram $out/bin/gitea \
      --prefix PATH : ${
        lib.makeBinPath [
          bash
          git
          gzip
          openssh
        ]
      }
  '';

  meta = {
    inherit (oldAttrs.meta) description broken mainProgram;
    inherit homepage;
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ malik ] ++ oldAttrs.meta.maintainers;
  } // lib.optionalAttrs (version != "git") {
    changelog = "${homepage}/releases/tag/v${version}";
  };
}
)
