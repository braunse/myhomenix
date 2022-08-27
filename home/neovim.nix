{ config, pkgs, lib, ... }:

with builtins;
with lib;

let
  cfg = config.mine.neovim;

  vim-night-owl =
    let
      src = import ../utils/flake-dep.nix "vim-night-owl";
    in
    pkgs.vimUtils.buildVimPlugin {
      name = "night-owl.vim-${toString src.lastModified}";
      inherit src;
    };

  nativeServerConfig = types.submodule {
    options = {
      config = mkOption {
        type = types.str;
        default = "";
      };

      plugins = mkOption {
        type = types.listOf types.path;
        default = [ ];
      };
    };
  };
in
{
  options = {
    mine.neovim = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };

      native-lsp = {
        enable = mkOption {
          type = types.bool;
          default = true;
        };

        servers = mkOption {
          type = types.attrsOf nativeServerConfig;
          default = { };
        };
      };
    };
  };

  imports = [
    ./neovim/keymap.nix
  ];

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      extraConfig = ''
        set nocompatible
        set showmatch
        set ignorecase
        set mouse=v
        set hlsearch
        set incsearch
        set tabstop=4
        set softtabstop=4
        set expandtab
        set shiftwidth=4
        set autoindent
        set number
        set wildmode=longest,list
        set cc=100
        filetype plugin indent on
        syntax on
        set mouse=a
        set clipboard=unnamedplus
        filetype plugin on
        set cursorline
        set ttyfast      

        if (has(" termguicolors "))
          set termguicolors
        endif
        syntax enable
        colorscheme everforest

        set splitright
        set splitbelow

        inoremap ,. <Esc>
        vnoremap ,. <Esc>

        let g:mapleader = ','
        inoremap <C-Space> <Cmd>lua require"cmp".complete()<CR>
        "inoremap <silent><expr> <c-space> coc#refresh()
        "inoremap <silent><expr> <cr> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
        "inoremap <silent><expr> <esc> coc#pum#visible() ? coc#pum#cancel() : "\<Esc>"

        "autocmd CursorHold * silent call CocActionAsync('highlight')
        "autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
      
        set completeopt=menu,menuone,noselect

        lua <<EOL
          local cmp = require("cmp")
          cmp.setup({
            sources = {
              ${optionalString cfg.native-lsp.enable ''
                { name = "nvim_lsp" },
              ''}
              { name = "vsnip" },
            },
            snippet = {
              expand = function(args)
                vim.fn["vsnip#anonymous"](args.body)
              end,
            },
            mapping = cmp.mapping.preset.insert({
              ["<CR>"] = cmp.mapping.confirm({ select = true }),
              ["<Tab>"] = function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                else
                  fallback()
                end
              end,
              ["<S-Tab>"] = function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                else
                  fallback()
                end
              end
            }),
            window = {
              completion = cmp.config.window.bordered(),
              documentation = cmp.config.window.bordered(),
            },
          })

          # ''${optionalString cfg.native-lsp.enable 
          #   (concatMapStringsSep "\n" (server:  }
          EOL
      '';
      coc = {
        enable = false;
        settings = {
          suggest.disableKind = true;
          suggest.snippetsSupport = false;
          diagnostic = {
            virtualText = true;
            virtualTextCurrentLineOnly = false;
            virtualTextLines = 1;
            virtualTextPrefix = "---";
          };
          "list.height" = 20;
          "codeLens.enable" = true;
          "coc.preferences.enableMarkdown" = true;
          "coc.preferences.jumpCommand" = "tab drop";
        };
      };
      plugins = with pkgs.vimPlugins; [
        # Cosmetics and UI
        vim-airline
        {
          plugin = vim-airline-themes;
          config = ''
            let g:airline_theme = "everforest"
          '';
        }
        vim-devicons
        vim-startify # Fancy start screen
        nvim-web-devicons
        vim-night-owl
        everforest

        # File and project management
        nerdtree
        nvim-tree-lua
        ctrlp
        {
          plugin = barbar-nvim;
          config = ''
            let bufferline = get(g:, 'bufferline', {})
            let bufferline.animation = v:true
            let bufferline.auto_hide = v:true
          '';
        }

        # Completion
        nvim-cmp
        cmp-nvim-lsp
        cmp-vsnip
        vim-vsnip

        # Programming
        nerdcommenter
        # coc-json

        # Environment
        direnv-vim

        # Snippets
        ultisnips
        vim-snippets

        # Utilities
        indent-blankline-nvim
      ];
    };
  };
}

