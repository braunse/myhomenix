{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.mine.dev.elixir;

  beamPkgs = pkgs.beam.packages.${cfg.erlangVersion};
in
{
  options.mine.dev.elixir = {
    enable = mkEnableOption "Elixir";

    erlangVersion = mkOption {
      type = types.str;
      default = "erlangR25";
    };

    elixirVersion = mkOption {
      type = types.str;
      default = "elixir_1_13";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      beamPkgs.${cfg.elixirVersion}
      beamPkgs.erlang
      beamPkgs.elixir_ls
    ];

    mine.emacs.modules.lang.elixir = ["lsp"];
    programs.doom-emacs.extraConfig = ''
      (setq lsp-elixir-local-server-command "${beamPkgs.elixir_ls}/bin/language_server.sh")
      (setq lsp-elixir-server-command "${beamPkgs.elixir_ls}/bin/language_server.sh")
    '';
  };
}
