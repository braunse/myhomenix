{ config, pkgs, lib, ... }:
with lib;
let cfg = config.mine.dev.nix;
in
{
  options = {
    mine.dev.nix = {
      enable = mkEnableOption "Nix";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = with pkgs; [
        nixpkgs-fmt
      ];

      programs.neovim = {
        plugins = with pkgs.vimPlugins; [
          vim-nix
        ];
        coc.settings.languageserver.rnix-lsp = {
          command = "${pkgs.rnix-lsp}/bin/rnix-lsp";
          filetypes = [ "nix" ];
        };
      };
    })
  ];
}
