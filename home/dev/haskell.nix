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

      useSystemTools = mkEnableOption "Use system-installed Haskell";

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
      programs.zsh.initExtra = ''
        if [ -d "$HOME/.ghcup" ]; then PATH="$HOME/.ghcup/bin:$PATH"; fi
      '';
    }

    (mkIf cfg.enable {
      home.packages = mkIf (!cfg.useSystemTools) [
        cfg.ghc.package
        pkgs.cabal-install
        pkgs.cabal2nix
        pkgs.hpack
        pkgs.stack
        hls
      ];

      mine.emacs.modules.lang.haskell = [ "lsp" ];
      programs.doom-emacs.extraConfig = mkIf (!cfg.useSystemTools) ''
        (pushnew! exec-path "${hls}/bin")
        (setq lsp-haskell-server-path "${hls}/bin/haskell-language-server-wrapper")
      '';

      programs.neovim = mkIf (!cfg.useSystemTools) {
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
