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
      ];

      mine.emacs.modules.lang.purescript = ["lsp"];
    })
  ];
}
