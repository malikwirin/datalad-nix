{ authors, title, version, lib, writeShellScriptBin, cffconvert, dhall, dhall-yaml, gnused }:

let
  dhallScript = ./generator.dhall;
  
  authorsToDhall = authors: 
    let
      authorToDhall = author:
        let
          mkField = name: value:
            if value != null 
            then ''${name} = Some "${lib.escape ["\""] value}"'' 
            else ''${name} = None Text'';

          addWebsiteIfGH = author:
            if author ? website && author.website != null then author
            else if author ? github && author.github != null then author // { website = "https://github.com/${author.github}"; }
            else author;

          ensureName = unvalidAuthor:
            let
              author = addWebsiteIfGH unvalidAuthor;
            in
              if author.name != null then author
              else if author ? "given-names" && author."given-names" != null && author ? "family-names" && author."family-names" != null then author
              else author // { name = author.github or "n/a"; }; # Fallback

          validAuthor = ensureName author;

          fields = [
            (mkField "name" validAuthor.name or null)
            (mkField "given-names" (validAuthor."given-names" or null))
            (mkField "family-names" (validAuthor."family-names" or null))
            (mkField "email" validAuthor.email or null)
            (mkField "affiliation" validAuthor.affiliation or null)
            (mkField "orcid" validAuthor.orcid or null)
            (mkField "website" validAuthor.website or null)
          ];
        in
        "{ ${lib.concatStringsSep ", " fields} }";
      
      authorsList = lib.concatMapStrings (a: "${authorToDhall a}, ") authors;
    in
    "[ ${lib.removeSuffix ", " authorsList} ]";

  dhallExpr = ''
    let Citation = ${dhallScript}
    in Citation.createCitation ${authorsToDhall authors} "${lib.escape ["\""] title}" "${version}"
  '';
  
in writeShellScriptBin "nix2citation" ''
  set -e
  
  tmpYamlFile=$(mktemp)
  tmpCffFile=$(mktemp)
  
  echo '${dhallExpr}' | ${dhall}/bin/dhall | ${dhall-yaml}/bin/dhall-to-yaml-ng > $tmpYamlFile
  ${gnused}/bin/sed 's/cffVersion:/cff-version:/g' $tmpYamlFile > $tmpCffFile

  if ${cffconvert}/bin/cffconvert --validate -i $tmpCffFile 2>/dev/null; then
    cp $tmpCffFile CITATION.cff
    echo "✅ CITATION.cff was generated and validated successfully"
    rm $tmpYamlFile $tmpCffFile
  else
    echo "❌ Validation failed. CITATION.cff was not created."
    echo "--- Generated file contents ---"
    cat $tmpCffFile
    echo "-----------------------------"
    # Create validation error message
    ${cffconvert}/bin/cffconvert --validate -i $tmpCffFile || true
    rm $tmpYamlFile $tmpCffFile
    exit 1
  fi
''
