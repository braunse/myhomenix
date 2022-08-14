{ config, lib, pkgs, ... }:
with builtins;
with lib;
let
  cfg = config.mine.k8s;
in
{
  options.mine.k8s = {
    enable = mkEnableOption "Kubernetes";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      kubectl
      kubectx
      k9s
      kubernetes-helm
      krew
    ];

    home.sessionPath = [ "$HOME/.krew/bin" ];
  };
}
