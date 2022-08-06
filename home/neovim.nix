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
      inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<CR>"

      autocmd CursorHold * silent call CocActionAsync('highlight')
      autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

      nnoremap <Leader>tn :NERDTreeToggle<CR>
      nnoremap <Leader>fn :NERDTreeFind<CR>
      nnoremap <Leader>gn :NERDTreeFocus<CR>

      nnoremap <silent> <A-,> <Cmd>BufferPrevious<CR>
      nnoremap <silent> <A-.> <Cmd>BufferNext<CR>
      nnoremap <silent> <A-;> <Cmd>BufferMovePrevious<CR>
      nnoremap <silent> <A-:> <Cmd>BufferMoveNext<CR>
      nnoremap <silent> <A-1> <Cmd>BufferGoto 1<CR>
      nnoremap <silent> <A-2> <Cmd>BufferGoto 2<CR>
      nnoremap <silent> <A-3> <Cmd>BufferGoto 3<CR>
      nnoremap <silent> <A-4> <Cmd>BufferGoto 4<CR>
      nnoremap <silent> <A-5> <Cmd>BufferGoto 5<CR>
      nnoremap <silent> <A-6> <Cmd>BufferGoto 6<CR>
      nnoremap <silent> <A-7> <Cmd>BufferGoto 7<CR>
      nnoremap <silent> <A-8> <Cmd>BufferGoto 8<CR>
      nnoremap <silent> <A-9> <Cmd>BufferGoto 9<CR>
      nnoremap <silent> <A-0> <Cmd>BufferLast<CR>
      nnoremap <silent> <A-p> <Cmd>BufferPin<CR>
      nnoremap <silent> <A-c> <Cmd>BufferClose<CR>
      nnoremap <silent> <A-g> <Cmd>BufferPick<CR>

      nnoremap <Leader>bb <Cmd>BufferPick<CR>
      nnoremap <Leader>b, <Cmd>BufferPrevious<CR>
      nnoremap <Leader>b. <Cmd>BufferNext<CR>
      nnoremap <Leader>bm, <Cmd>BufferMovePrevious<CR>
      nnoremap <Leader>bm. <Cmd>BufferMoveNext<CR>
      nnoremap <Leader>b1 <Cmd>BufferGoto 1<CR>
      nnoremap <Leader>b2 <Cmd>BufferGoto 2<CR>
      nnoremap <Leader>b3 <Cmd>BufferGoto 3<CR>
      nnoremap <Leader>b4 <Cmd>BufferGoto 4<CR>
      nnoremap <Leader>b5 <Cmd>BufferGoto 5<CR>
      nnoremap <Leader>b6 <Cmd>BufferGoto 6<CR>
      nnoremap <Leader>b7 <Cmd>BufferGoto 7<CR>
      nnoremap <Leader>b8 <Cmd>BufferGoto 8<CR>
      nnoremap <Leader>b9 <Cmd>BufferGoto 9<CR>
      nnoremap <Leader>b0 <Cmd>BufferLast<CR>
      nnoremap <Leader>bc <Cmd>BufferClose<CR>
      nnoremap <Leader>bp <Cmd>BufferPin<CR>
      nnoremap <Leader>bon <Cmd>BufferOrderByBufferNumber<CR>
      nnoremap <Leader>bod <Cmd>BufferOrderByDirectory<CR>
      nnoremap <Leader>bol <Cmd>BufferOrderByLanguage<CR>
      nnoremap <Leader>bow <Cmd>BufferOrderByWindowNumber<CR>
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
      nerdtree
      nerdcommenter
      direnv-vim
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
      {
        plugin = barbar-nvim;
        config = ''
          let bufferline = get(g:, 'bufferline', {})
          let bufferline.animation = v:true
          let bufferline.auto_hide = v:true
        '';
      }
      {
        plugin = which-key-nvim;
        config = ''
          lua << EOF
            local wk = require("which-key")

            wk.setup {
            }

            wk.register({
              g = {
                name = "Go to ...",
                d = "Definition (LSP)",
                i = "Implementation (LSP)",
                t = "Type Definition (LSP)",
                n = "NerdTree",
              },
              a = {
                name = "Action",
                h = "Hover (LSP)"
              },
              e = {
                name = "Diagnostics",
                n = "Next (LSP)",
                p = "Prev (LSP)"
              },
              f = {
                name = "Find",
                r = "References (LSP)",
                n = "NerdTree"
              },
              r = {
                name = "Refactor",
                n = "Rename (LSP)",
                r = "Refactor (LSP)"
              },
              q = {
                name = "Quick",
                f = "Fix Current (LSP)"
              },
              k = {
                name = "List",
                d = "Diagnostics (LSP)",
                c = "Commands (LSP)",
                o = "Outline (LSP)",
                r = "Resume"
              },
              t = {
                name = "Toggle",
                n = "NerdTree"
              },
              b = {
                name = "Buffers",
                b = "Pick",
                [","] = "Previous",
                ["."] = "Next",
                m = {
                  name = "Move",
                  [","] = "Previous",
                  ["."] = "Next",
                },
                ["1-9"] = "Go to buffer number _",
                ["1"] = "which_key_ignore",
                ["2"] = "which_key_ignore",
                ["3"] = "which_key_ignore",
                ["4"] = "which_key_ignore",
                ["5"] = "which_key_ignore",
                ["6"] = "which_key_ignore",
                ["7"] = "which_key_ignore",
                ["8"] = "which_key_ignore",
                ["9"] = "which_key_ignore",
                ["0"] = "Go to last buffer",
                c = "Close",
                p = "Pin",
                o = {
                  name = "Order by ...",
                  n = "Number",
                  d = "Directory",
                  l = "Language",
                  w = "Window Number"
                },
              },
            }, {
              prefix = "<Leader>"
            })
          EOF
        '';
      }
    ];
  };
}

