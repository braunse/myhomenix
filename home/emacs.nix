{ config, lib, pkgs, ... }:

with builtins;
with lib;

let
  cfg = config.mine.emacs;

  earlySections = [
    "input"
    "completion"
    "ui"
    "editor"
    "emacs"
    "term"
    "checkers"
    "tools"
    "os"
    "lang"
    "email"
    "app"
  ];

  lateSections = [
    "config"
  ];

  customSections = naturalSort (subtractLists (earlySections ++ lateSections) (attrNames cfg.modules));

  sections = earlySections ++ customSections ++ lateSections;

  initFile =
    let
      args =
        concatMapStringsSep "\n\n       "
          (section:
            let moduleNames = attrNames cfg.modules.${section};
                moduleEntries = concatMapStringsSep "\n       "
              (moduleName:
                let moduleFlags = cfg.modules.${section}.${moduleName};
                in if moduleFlags != null && moduleFlags != [ ] then
                  "(${moduleName} +${concatStringsSep " +" moduleFlags})"
                else
                  moduleName
              )
              moduleNames;
    in ":${section}\n       ${moduleEntries}")
          sections;
    in
    pkgs.writeText "init.el" "(doom! ${args})";

  doomDir = pkgs.runCommandNoCC "doom.d" { } ''
    mkdir $out
    cp ${../config/doom.d/packages.el} $out/packages.el
    cp ${../config/doom.d/config.el} $out/config.el
    ln -s ${initFile} $out/init.el
  '';

in
{
  options.mine.emacs = {
    enable = mkEnableOption "Emacs";

    modules = mkOption {
      type = types.attrsOf (types.attrsOf (types.nullOr (types.listOf types.str)));
    };
  };

  config = {
    programs.doom-emacs = mkIf cfg.enable {
      enable = true;
      doomPrivateDir = doomDir;
      emacsPackagesOverlay = self: super: { };
    };

    mine.emacs.modules = {
      input = { };
      completion = {
        company = [ ];
        vertico = [ ];
      };
      ui = {
        doom = [ ];
        doom-dashboard = [ ];
        doom-quit = [ ];
        hl-todo = [ ];
        indent-guides = [];
        ligatures = [ "extra" ];
        modeline = [ ];
        ophints = [ ];
        popup = [ "defaults" ];
        treemacs = [ ];
        unicode = [];
        vc-gutter = [ ];
        vi-tilde-fringe = [ ];
        workspaces = [ ];
      };
      editor = {
        evil = [ "everywhere" ];
        file-templates = [ ];
        fold = [ ];
        format = [ "onsave" ];
        parinfer = [ ];
        snippets = [ ];
      };
      emacs = {
        dired = [ ];
        electric = [ ];
        undo = [ ];
        vc = [ ];
      };
      term = {
        vterm = [ ];
      };
      checkers = {
        syntax = [ ];
      };
      tools = {
        debugger = [ ];
        direnv = [ ];
        editorconfig = [ ];
        eval = [ "overlay" ];
        lookup = [ ];
        lsp = [ ];
        magit = [ ];
        rgb = [ ];
        tree-sitter = [ ];
        tmux = [ ];
        upload = [ ];
      };
      os = { };
      lang = {
        data = [ ];
        json = [ "lsp" "tree-sitter" ];
        markdown = [ ];
        rest = [ "jq" ];
        yaml = [ "lsp" ];
      };
      email = { };
      app = { };
      config = {
        default = [ "bindings" "smartparens" ];
      };
    };
  };
}
