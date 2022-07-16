{ config, pkgs, ... }: {
  programs.tmux = {
    enable = true;
    historyLimit = 100000;
    plugins = with pkgs.tmuxPlugins; [
      nord
    ];
    sensibleOnTop = true;
    terminal = "screen-256color";
    shortcut = "b";

    extraConfig = ''
      set-window-option -g aggressive-resize
      set -g base-index 1
      setw -g pane-base-index 1
      set -g renumber-windows on

      bind-key v split-window -h -l 100 -c '#{pane_current_path}'
      bind-key h split-window -v -l 30 -c '#{pane_current_path}'

      bind-key C-M-Left swap-window -t -1
      bind-key C-M-Right swap-window -t +1

      bind-key M-Left previous-window
      bind-key M-Right next-window

      bind-key Left select-pane -L
      bind-key Right select-pane -R
      bind-key Up select-pane -U
      bind-key Down select-pane -D

      bind-key S-Left resize-pane -L 10
      bind-key S-Right resize-pane -R 10
      bind-key S-Up resize-pane -U 10
      bind-key S-Down resize-pane -D 10

      bind-key C-Up swap-pane -U
      bind-key C-Down swap-pane -D

      bind-key r source-file "~/.config/tmux/tmux.conf"\; display "Reloaded!"

      set -g focus-events on
      set -g mouse on
      set -g set-titles on
      set -g set-titles-string "#T"

      bind-key = select-layout even-horizontal
      bind-key | select-layout even-vertical
    '';
  };
}
