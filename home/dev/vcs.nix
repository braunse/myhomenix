{ config, pkgs, lib, ... }:
with lib;
with types;

let
  cfg = config.mine.vcs;
in
{
  options = {
    mine.vcs = {
      enableFossil = mkEnableOption "Fossil";
    };
  };

  config = mkMerge [
    (mkIf config.programs.git.enable {
      programs.zsh.oh-my-zsh.plugins = [ "git" ];
    })

    (mkIf cfg.enableFossil {
      home.packages = [ pkgs.fossil ];
      programs.zsh.oh-my-zsh.plugins = [ "fossil" ];
    })
  ];
}
