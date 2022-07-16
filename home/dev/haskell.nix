{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.mine.dev.haskell;
in
{
  options = {
    mine.dev.haskell = {
      enable = mkEnableOption "Haskell";

      ghcVersion = mkOption {
        type = types.str;
        default = "ghc8107";
      };

      ghc.package = mkOption {
        type = types.package;
      };
    };
  };

  config = mkMerge [
    {
      mine.dev.haskell.ghc.package = mkDefault pkgs.haskell.compiler.${cfg.ghcVersion};
    }

    (mkIf cfg.enable {
      home.packages = [
        cfg.ghc.package
        pkgs.cabal-install
        pkgs.cabal2nix
      ];

      programs.neovim = {
        coc.settings.languageserver.haskell = {
          command = "${pkgs.haskell-language-server}/bin/haskell-language-server-wrapper";
          args = [ "--lsp" ];
          rootPatterns = [ "stack.yaml" "cabal.project" "*.cabal" "package.yaml" "hie.yaml" ];
          filetypes = [ "haskell" "lhaskell" ];
          initialization = {
            languageServerHaskell = { };
          };
        };
      };
    })

  ];
}
