{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  cfg = config.mine.dev.golang;
in
{
  options.mine.dev.golang = {
    enable = mkEnableOption "Go Language";

    package = mkOption {
      type = types.package;
      default = pkgs.go_1_18;
    };

    enableGopls = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = with pkgs; [
        cfg.package
      ];

      mine.emacs.modules.lang.go = ["lsp" "tree-sitter"];
      programs.doom-emacs.extraConfig = ''
        (pushnew! exec-path "${pkgs.gopls}/bin")
      '';

      programs.neovim.extraConfig = ''
        lua <<EOL
          require("lspconfig").gopls.setup {
          }
        EOL
      '';

      programs.neovim.coc.settings.languageserver.gopls = {
        command = "${pkgs.gopls}/bin/gopls";
        rootPatterns = [ "go.mod" ];
        filetypes = [ "go" ];
      };
    })
  ];
}
