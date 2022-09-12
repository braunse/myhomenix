{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.mine.dev.purescript;

in
{
  options = {
    mine.dev.purescript = {
      enable = mkEnableOption "PureScript";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = [
        pkgs.purescript
        pkgs.spago
        pkgs.pulp
        pkgs.psc-package
        pkgs.dhall
        pkgs.purescript-psa
      ];

      programs.doom-emacs.extraConfig = ''
        (pushnew! exec-path "${pkgs.nodePackages.purescript-language-server}/bin")
      '';

      mine.emacs.modules.lang.dhall = [ ];
      mine.emacs.modules.lang.purescript = [ "lsp" ];
    })
  ];
}
