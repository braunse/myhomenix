{ lib
, fetchFromGitHub
, buildDunePackage
, stdune
}:

let
  version = "1.11.4";
  src = fetchFromGitHub {
    owner = "ocaml";
    repo = "ocaml-lsp";
    rev = version;
    sha256 = "sha256-5wnjxWWOeqQ/PUZDTs4UG7w3Yf0CJ7XT1YwELvkDj18=";
  };

  lsp-server = buildDunePackage rec {
    pname = "ocaml-lsp-server";
    duneVersion = "3";

    inherit src version;

    buildInputs = [ stdune ];
  };

in
lsp-server

