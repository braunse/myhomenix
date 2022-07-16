inputs:
{ config, pkgs, ... }:
{
  lib.mine.inputs = inputs;

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    nixFlakes
  ];

  home.file.".nixpkgs".source = inputs.nixpkgs;
  nix.registry.nixpkgs = {
    from = { id = "nixpkgs"; type = "indirect"; };
    flake = inputs.nixpkgs;
  };
  nix.registry.home-manager = {
    from = { id = "home-manager"; type = "indirect"; };
    flake = inputs.home-manager;
  };
  home.sessionVariables.NIX_PATH = "nixpkgs=${inputs.nixpkgs}:home-manager=${inputs.home-manager}";
}
