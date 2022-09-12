{ config, lib, pkgs, ... }:
with builtins;
with lib;
let
  cfg = config.mine.dev.ocaml;
in
{
  options.mine.dev.ocaml = {
    enable = mkEnableOption "OCaml";

    packageSet = mkOption {
      type = types.attrs;
      default = pkgs.ocaml-ng.ocamlPackages_4_14;
    };

    compilerPkg = mkOption {
      type = types.package;
    };

    lspServerPkg = mkOption {
      type = types.package;
    };

    dunePkg = mkOption {
      type = types.package;
    };

    opamPkg = mkOption {
      type = types.package;
    };

    packages = mkOption {
      type = types.listOf types.str;
    };
  };

  config = mkMerge [
    {
      mine.dev.ocaml.compilerPkg = mkDefault cfg.packageSet.ocaml;
      mine.dev.ocaml.lspServerPkg = mkDefault cfg.packageSet.ocaml-lsp;
      mine.dev.ocaml.dunePkg = mkDefault (cfg.packageSet.dune_3 or cfg.packageSet.dune_2);
      mine.dev.ocaml.opamPkg = mkDefault pkgs.opam;
      mine.dev.ocaml.packages = mkDefault [ "utop" ];
      programs.zsh.initExtra = ''
        if [ -r "$HOME/.opam/opam-init/init.zsh" ]; then source "$HOME/.opam/opam-init/init.zsh" >/dev/null 2>/dev/null; fi
      '';
    }

    (mkIf cfg.enable {
      home.packages = [
        cfg.compilerPkg
        cfg.dunePkg
        cfg.opamPkg
        pkgs.ocamlformat
      ] ++ (map (name: cfg.packageSet.${name}) cfg.packages);

      mine.emacs.modules.lang.ocaml = [ "lsp" "tree-sitter" ];
      programs.doom-emacs.extraConfig = ''
        (pushnew! exec-path "${cfg.lspServerPkg}/bin")
      '';

      programs.neovim.coc.settings.languageserver.ocaml-lsp = {
        command = "${cfg.lspServerPkg}/bin/ocamllsp";
        filetypes = [ "ocaml" "reason" ];
      };
    })
  ];
}
