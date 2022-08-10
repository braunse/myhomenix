{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    fx
    du-dust
    xsv
    ripgrep
    fd
    topgrade
  ];

  programs.bat.enable = true;
  programs.direnv.enable = true;
  programs.fzf.enable = true;
  programs.lsd.enable = true;
  programs.lsd.enableAliases = true;
  programs.zoxide.enable = true;
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    profileExtra = ''
      # Derive MANPATH from PATH
      unset MANPATH
    '';
    oh-my-zsh = {
      enable = true;
      plugins = [
        "asdf"
        "cabal"
        "direnv"
        "fd"
        "fzf"
        "lein"
        "mvn"
        "npm"
        "ripgrep"
        "rust"
        "stack"
        "sudo"
        "tmux"
        "yarn"
      ];
      theme = "dogenpunk";
      extraConfig = ''
        ZSH_TMUX_CONFIG="${config.xdg.configHome}/tmux/tmux.conf"
      '';
    };
  };

  xdg.configFile."alacritty/alacritty.yml".source = ../config/alacritty.yml;
}
