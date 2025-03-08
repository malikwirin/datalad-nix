let Author =
      { name : Optional Text
      , given-names : Optional Text
      , family-names : Optional Text
      , email : Optional Text
      , affiliation : Optional Text
      , orcid : Optional Text
      , website : Optional Text
      }

-- Erstelle eine komplette Citation-Datei
let createCitation =
      \(authors : List Author) ->
      \(title : Text) ->
      \(version : Text) ->
        { cffVersion = "1.2.0"
        , message = "If you use this software, please cite it as below."
        , title = title
        , version = version
        , authors = authors
        }

in  { Author = Author
    , createCitation = createCitation
    }
