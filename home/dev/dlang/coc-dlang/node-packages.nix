# This file has been generated by node2nix 1.11.1. Do not edit!

{ nodeEnv, fetchurl, fetchgit, nix-gitignore, stdenv, lib, globalBuildInputs ? [ ] }:

let
  sources = { };
in
{
  coc-dlang = nodeEnv.buildNodePackage {
    name = "coc-dlang";
    packageName = "coc-dlang";
    version = "1.1.2";
    src = fetchurl {
      url = "https://registry.npmjs.org/coc-dlang/-/coc-dlang-1.1.2.tgz";
      sha512 = "MyR3DKRooiVaJ/ZzYwwRkj8NR8W2Tk4EhVE2paKZqIy6dvPfvzmygRGiQkI9sMEDmlClO5VXU6aYH/aALFQwiQ==";
    };
    buildInputs = globalBuildInputs;
    meta = {
      description = "dlang support for coc";
      license = "MIT";
    };
    production = true;
    bypassCache = true;
    reconstructLock = true;
  };
}
