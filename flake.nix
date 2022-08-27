{
  description = "My Home Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";

    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
    nix-doom-emacs.inputs.nixpkgs.follows = "nixpkgs";
    vim-night-owl = { url = "github:haishanh/night-owl.vim"; flake = false; };
    coc-dlang = { url = "github:vushu/coc-dlang"; flake = false; };
  };

  outputs = ins@{ self, nixpkgs, flake-utils, home-manager, nix-doom-emacs, ... }:
    let
      system = "x86_64-linux";
      username = "seb";
      defaultConfig = { ... }: {
        imports = [
          (import ./home/basic.nix ins)
          nix-doom-emacs.hmModule
          ./home/emacs.nix
          ./home/neovim.nix
          ./home/tmux.nix
          ./home/utils.nix
          ./home/dev/dlang.nix
          ./home/dev/nim.nix
          ./home/dev/nix.nix
          ./home/dev/vcs.nix
          ./home/dev/rust.nix
          ./home/dev/golang.nix
          ./home/dev/haskell.nix
          ./home/dev/frontend.nix
          ./home/dev/ocaml.nix
          ./home/k8s.nix
        ];

        config = {
          home.username = username;
          home.homeDirectory = "/home/${username}";
          home.stateVersion = "21.11";
          mine.emacs.enable = true;
          mine.neovim.enable = false;
          mine.k8s.enable = true;
          mine.vcs.enableFossil = true;
          mine.dev.dlang.enable = true;
          mine.dev.frontend.enable = true;
          mine.dev.golang.enable = true;
          mine.dev.haskell.enable = true;
          mine.dev.nim.enable = true;
          mine.dev.nim.enableLsp = true;
          mine.dev.nix.enable = true;
          mine.dev.ocaml.enable = true;
          mine.dev.rust = {
            enable = true;
            components = [
              "cargo"
              "clippy"
              "rustc"
              "rust-std"
              "rustfmt"
              "rust-docs"
              "miri"
              "rust-analyzer-preview"
              "llvm-tools-preview"
              "rust-src"
            ];
            targetComponents = {
              "wasm32-unknown-unknown" = [ "rust-std" ];
              "wasm32-wasi" = [ "rust-std" ];
              "x86_64-pc-windows-gnu" = [ "rust-std" ];
              "x86_64-pc-windows-msvc" = [ "rust-std" ];
            };
          };
          programs.doom-emacs.extraConfig = ''
            (setq doom-font (font-spec :family "FiraCode Nerd Font" :size 12 :weight 'semi-light))
            (setq doom-theme 'doom-one)
            (setq display-line-numbers-type t)
            (setq org-directory "~/org/")
          '';
        };
      };
    in
    let
      sysdeps =
        flake-utils.lib.eachDefaultSystem
          (system:
            let
              pkgs = nixpkgs.legacyPackages.${system};
            in
            { });
      sysindeps = {
        homeConfigurations."ostwdev" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};

          modules = [
            ({ config, pkgs, ... }: {
              imports = [
                defaultConfig
              ];
            })
          ];
        };
      };
    in
    sysdeps // sysindeps;
}
