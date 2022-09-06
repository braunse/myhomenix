{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.mine.dev.haskell;

  hls = pkgs.haskell-language-server.override {
    supportedGhcVersions = cfg.hls.supportedVersions;
  };
in
{
  options = {
    mine.dev.haskell = {
      enable = mkEnableOption "Haskell";

      ghcVersion = mkOption {
        type = types.str;
        default = "ghc924";
      };

      ghc.package = mkOption {
        type = types.package;
      };

      hls.supportedVersions = mkOption {
        type = types.listOf types.str;
        default = [ "8107" "902" "924" ];
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
        pkgs.hpack
        pkgs.stack
        hls
      ];

      mine.emacs.modules.lang.haskell = [ "lsp" ];
      programs.doom-emacs.extraConfig = ''
        (pushnew! exec-path "${hls}/bin")
      '';

      programs.neovim = {
        coc.settings.languageserver.haskell = {
          command = "${hls}/bin/haskell-language-server-wrapper";
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
