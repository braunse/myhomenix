{ config, pkgs, lib, ... }:

with lib;

let cfg = config.mine.dev.nim;

in
{
  options = {
    mine.dev.nim = {
      enable = mkEnableOption "Nim";
      enableLsp = mkEnableOption "NimLSP";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = [
        pkgs.nim
        pkgs.nimlsp
      ];

      mine.emacs.modules.lang.nim = [];

      programs.neovim = {
        plugins = [ pkgs.vimPlugins.nim-vim ];
        coc.settings.languageserver.nim = mkIf cfg.enableLsp {
          command = "${pkgs.nimlsp}/bin/nimlsp";
          filetypes = [ "nim" ];
        };
      };
    })
  ];
}
