{ config, lib, pkgs, ... }:

with builtins;
with lib;

let
  cfg = config.mine.dev.scala;

  javaPackage = attrByPath [ "mine" "dev" "java" "jvm" ] pkgs.jdk config;

  java11Package = pkgs.jdk11;

in
{
  options.mine.dev.scala = {
    enable = mkEnableOption "Scala";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.scala_3
      pkgs.scalafmt
      pkgs.sbt
      pkgs.mill
      pkgs.scalafix
      javaPackage
    ];

    mine.emacs.modules.lang.scala = ["lsp" "tree-sitter"];
    programs.doom-emacs.extraConfig = ''
      (pushnew! exec-path "${pkgs.metals}/bin" "${pkgs.coursier}/bin" "${pkgs.bloop}/bin")
      (setq lsp-metals-server-command "${pkgs.metals}/bin/metals")
      (setq lsp-metals-java-home "${javaPackage}")
      (setq lsp-metals-sbt-script "${pkgs.sbt}/bin/sbt")
      (setq lsp-metals-gradle-script "${pkgs.gradle}/bin/gradle")
      (setq lsp-metals-maven-script "${pkgs.maven}/bin/mvn")
      (setq lsp-metals-mill-script "${pkgs.mill}/bin/mill")
    '';

    programs.neovim = {
      extraConfig = ''
        lua <<EOL
          local metals_config = require"metals".bare_config()
  
          metals_config.settings = {
            showImplicitArguments = true,
          }

          local capabilities = vim.lsp.protocol.make_client_capabilities()
          metals_config.capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)


          metals_config.on_attach = function(client, bufnr)
            require("metals").setup_dap()
          end

          local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
          vim.api.nvim_create_autocmd("FileType", {
            pattern = { "scala", "sbt" },
            callback = function()
              require("metals").initialize_or_attach(metals_config)
            end,
            group = nvim_metals_group
          })
        EOL
      '';

      plugins = with pkgs.vimPlugins; [
        nvim-metals
        plenary-nvim
        nvim-dap
      ];
    };
  };
}
