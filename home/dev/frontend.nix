{ config, pkgs, lib, ... }:
with lib;
let cfg = config.mine.dev.frontend;
in
{
  options = {
    mine.dev.frontend = {
      enable = mkEnableOption "Frontend Dev";
      enableCss = mkOption { type = types.bool; };
      enableHtml = mkOption { type = types.bool; };
      enableJs = mkOption { type = types.bool; };
      nodejs = mkOption { type = types.package; default = pkgs.nodejs-16_x; };
      yarn = mkOption { type = types.package; default = pkgs.yarn; };
      pnpm = mkOption { type = types.package; default = pkgs.nodePackages.pnpm; };
    };
  };

  config = mkMerge [
    {
      mine.dev.frontend.enableCss = mkDefault cfg.enable;
      mine.dev.frontend.enableHtml = mkDefault cfg.enable;
      mine.dev.frontend.enableJs = mkDefault cfg.enable;
    }

    (mkIf cfg.enable {
      programs.neovim = {
        plugins = with pkgs.vimPlugins; [ ]
          ++ optional cfg.enableCss coc-css
          ++ optional cfg.enableHtml coc-html
          ++ optional cfg.enableJs coc-tsserver;
      };

      programs.doom-emacs.extraConfig = ''
        (pushnew! exec-path "${pkgs.nodePackages.typescript-language-server}/bin" "${pkgs.deno}/bin")
      '';

      mine.emacs.modules.lang.javascript = [ "lsp" "tree-sitter" ];
      mine.emacs.modules.lang.web = [ "lsp" "tree-sitter" ];

      home.packages = with pkgs; [ ]
        ++ optionals cfg.enableJs [ cfg.nodejs cfg.yarn cfg.pnpm pkgs.deno ];
    })
  ];
}
