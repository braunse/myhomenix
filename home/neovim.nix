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
  imports = [
    ./neovim/keymap.nix
  ];

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
      inoremap <silent><expr> <c-space> coc#refresh()
      inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<CR>"

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

      # Programming
      nerdcommenter
      coc-json

      # Environment
      direnv-vim

      # Snippets
      ultisnips
      vim-snippets

      # Utilities
      indent-blankline-nvim
    ];
  };
}

