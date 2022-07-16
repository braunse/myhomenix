{ config, pkgs, ... }:

let
  vim-night-owl =
    let
      src = import ../utils/flake-dep.nix "vim-night-owl";
    in
    pkgs.vimUtils.buildVimPlugin {
      name = "night-owl.vim-${toString src.lastModified}";
      inherit src;
    };
in
{
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
      colorscheme night-owl

      set splitright
      set splitbelow

      inoremap ,. <Esc>
      vnoremap ,. <Esc>

      let g:mapleader = ','
      map <Leader>gd <Plug>(coc-definition)
      map <Leader>gi <Plug>(coc-implementation)
      map <Leader>gt <Plug>(coc-type-definition)
      map <Leader>ah :call CocActionAsync('doHover')<cr>
      map <Leader>en <Plug>(coc-diagnostic-next)
      map <Leader>ep <Plug>(coc-diagnostic-prev)
      map <Leader>fr <Plug>(coc-references)
      map <Leader>rn <Plug>(coc-rename)
      map <Leader>rr <Plug>(coc-refactor)
      map <Leader>qf <Plug>(coc-fix-current)
      map <Leader>al <Plug>(coc-codeaction-line)
      map <Leader>ac <Plug>(coc-codeaction-cursor)
      map <Leader>ao <Plug>(coc-codelens-action)
              
      nnoremap <Leader>kd :<C-u>CocList diagnostics<cr>
      nnoremap <Leader>kc :<C-u>CocList commands<cr>
      nnoremap <Leader>ko :<C-u>CocList outline<cr>
      nnoremap <Leader>kr :<C-u>CocListResume<cr>

      inoremap <silent><expr> <c-space> coc#refresh()
      inoremap <expr> <cr> pumvisible() ? "\<C-y> " : "\<CR> "

        autocmd CursorHold * silent call CocActionAsync('highlight')
        autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
    '';
    coc = {
      enable = true;
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
      vim-airline
      {
        plugin = vim-airline-themes;
        config = ''
          let g:airline_theme = "night_owl"
        '';
      }
      nerdcommenter
      vim-devicons
      ultisnips
      vim-snippets
      vim-startify
      indent-blankline-nvim
      which-key-nvim
      nvim-web-devicons
      nvim-tree-lua
      vim-night-owl
      coc-json

    ];
  };
}

