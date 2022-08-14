{ config, lib, pkgs, ... }:
with builtins;
with lib;
let
  renderName = n:
    if isList (match "[a-zA-Z]+" n)
    then n
    else "[\"${n}\"]";

  renderGroup = i: g:
    let
      name =
        if isString (g.group or null)
        then "name = ${renderString g.group}, \n${i}  "
        else "";
      mappings = removeAttrs g [ "group" ];
      renderedMappings = concatMapStringsSep ",\n${i}  "
        (n: "${renderName n} = ${render "${i}  " g.${n}}")
        (attrNames mappings);
    in
    "{\n${i}  ${name}${renderedMappings}\n${i}}";

  renderString = s:
    "\"${replaceStrings ["\""] ["\\\""] s}\"";

  renderMapping = m:
    if isString m then renderString m else
    let
      output =
        if m ? plug then "<Plug>${m.plug}"
        else if m ? cmd then "<Cmd>${m.cmd}<CR>"
        else if m ? to then m.to
        else throw "Could not evaluate mapping ${generators.toJSON {} m}";
      label = m.label or (
        if m.hide or false then "which_key_ignore"
        else m.plug or m.cmd or m.to
      );
      modeOpt = optionalString (m ? mode) ", mode = ${renderString m.mode}";
      prefixOpt = optionalString (m ? prefix) ", prefix = ${renderString m.prefix}";
      buffer = optionalString (m ? buffer) ", buffer = ${toString m.buffer}";
      silent = optionalString (m ? silent) ", silent = ${toString m.silent}";
      noremap = optionalString (m ? noremap) ", noremap = ${toString m.noremap}";
      opts = concatStrings [ modeOpt prefixOpt buffer silent noremap ];
    in
    "{ ${renderString output}, ${renderString label}${opts} }";

  render = i: km:
    if km ? group
    then renderGroup i km
    else renderMapping km;

  nkeymap = {
    a = {
      group = "Action";
      c = { plug = "coc-codeaction-cursor"; label = "Near Cursor (LSP)"; };
      f = { cmd = "CocCommand editor.action.formatDocument"; label = "Format (LSP)"; };
      h = { cmd = "call CocActionAsync('doHover')"; label = "Hover (LSP)"; };
      i = { cmd = "CocCommand editor.action.organizeImports"; label = "Organize Imports (LSP)"; };
      l = { plug = "coc-codeaction-line"; label = "On Line (LSP)"; };
      o = { plug = "coc-codelens-action"; label = "Code Lens (LSP)"; };
      q = { plug = "coc-fix-current"; label = "Quick Fix (LSP)"; };
      x = { cmd = "CocList commands"; label = "List LSP Commands"; };
    };
    b = {
      group = "Buffers";
      b = { cmd = "BufferPick"; label = "Pick"; };
      "." = { cmd = "BufferPrevious"; label = "Previous"; };
      "," = { cmd = "BufferNext"; label = "Next"; };
      m = {
        group = "Move ...";
        "," = { cmd = "BufferMovePrevious"; label = "Previous"; };
        "." = { cmd = "BufferMoveNext"; label = "Next"; };
      };
      "1-9" = "Go to buffer number";
      "1" = { cmd = "BufferGoto 1"; hide = true; };
      "2" = { cmd = "BufferGoto 2"; hide = true; };
      "3" = { cmd = "BufferGoto 3"; hide = true; };
      "4" = { cmd = "BufferGoto 4"; hide = true; };
      "5" = { cmd = "BufferGoto 5"; hide = true; };
      "6" = { cmd = "BufferGoto 6"; hide = true; };
      "7" = { cmd = "BufferGoto 7"; hide = true; };
      "8" = { cmd = "BufferGoto 8"; hide = true; };
      "9" = { cmd = "BufferGoto 9"; hide = true; };
      "0" = { cmd = "BufferLast"; label = "Last"; };
      c = { cmd = "BufferClose"; label = "Close"; };
      p = { cmd = "BufferPin"; label = "Pin"; };
      o = {
        group = "Order By ...";
        n = { cmd = "BufferOrderByBufferNumber"; label = "Number"; };
        l = { cmd = "BufferOrderByLanguage"; label = "Language"; };
        d = { cmd = "BufferOrderByDirectory"; label = "Directory"; };
        w = { cmd = "BufferOrderByWindowNumber"; label = "Window"; };
      };
    };
    d = {
      group = "Diagnostics";
      l = { cmd = "CocList diagnostics"; label = "List (LSP)"; };
      "." = { plug = "coc-diagnostic-next"; label = "Next (LSP)"; };
      "," = { plug = "coc-diagnostic-prev"; label = "Previous (LSP)"; };
    };
    f = {
      group = "Find";
      n = { cmd = "NERDTreeFind"; label = "NERDTree"; };
      r = { plug = "coc-references"; label = "References (LSP)"; };
    };
    g = {
      group = "Go to...";
      d = { plug = "coc-definition"; label = "Definition (LSP)"; };
      i = { plug = "coc-implementation"; label = "Implementation (LSP)"; };
      t = { plug = "coc-type-definition"; label = "Type Definition (LSP)"; };
      n = { cmd = "NERDTreeFocus"; label = "NERDTree"; };
      o = { cmd = "CocList outlint"; label = "Outline (LSP)"; };
    };
    r = {
      group = "Refactor";
      n = { plug = "coc-rename"; label = "Rename (LSP)"; };
      r = { plug = "coc-refactor"; label = "Refactor (LSP)"; };
    };
    t = {
      group = "Toggle";
      n = { cmd = "NERDTreeToggle"; label = "NERDTree"; };
    };
  };

  script = pkgs.writeText "which-key.lua" ''
    local wk = require("which-key")

    wk.setup {
    }

    wk.register(
      ${renderGroup "  " nkeymap},
      {
        prefix = "<Leader>"
      }
    )
  '';
in
{
  config.programs.neovim = {
    plugins = [
      {
        plugin = pkgs.vimPlugins.which-key-nvim;
        config = ''
          luafile ${script}
        '';
      }
    ];
  };
}
