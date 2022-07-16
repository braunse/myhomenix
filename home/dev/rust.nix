{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.mine.dev.rust;
  fenix = config.lib.mine.inputs.fenix.packages.${pkgs.system};

  selectChannel = from: channel:
    if channel == "latest"
    then from.latest
    else if channel == "stable"
    then from.stable
    else
      from.toolchainOf {
        inherit (cfg) channel;
        date = cfg.nightlyDate;
        sha256 = cfg.manifestSha256;
      };
  rustChannel = selectChannel fenix;
  target = t: fenix.targets.${t};
  targetChannel = t: selectChannel (target t);

  combinedToolchain =
    let
      selectedChannel = rustChannel cfg.channel;
      components = map (name: selectedChannel.${name}) cfg.components;
      targetComponents = concatMap
        (target:
          let
            components = cfg.targetComponents.${target};
            channel = targetChannel target cfg.channel;
          in
          map (component: channel.${component}) components)
        (attrNames cfg.targetComponents);
    in
    fenix.combine (components ++ targetComponents);
in
{
  options = {
    mine.dev.rust = {
      enable = mkEnableOption "Rust";

      channel = mkOption {
        type = types.str;
        default = "latest";
      };

      toolchainPackage = mkOption {
        type = types.package;
      };

      nightlyDate = mkOption {
        type = types.nullOr types.str;
        default = null;
      };

      manifestSha256 = mkOption {
        type = types.str;
        default = fakeSha256;
      };

      components = mkOption {
        type = types.listOf types.str;
        default = [
          "cargo"
          "clippy"
          "rustc"
          "rust-std"
          "rustfmt"
          "rust-docs"
        ];
      };

      targetComponents = mkOption {
        type = types.attrsOf (types.listOf types.str);
        default = { };
      };
    };
  };

  config = mkMerge [
    {
      mine.dev.rust.toolchainPackage = mkDefault combinedToolchain;
    }

    (mkIf cfg.enable {
      home.packages = [ cfg.toolchainPackage ];

      programs.neovim = {
        plugins = with pkgs.vimPlugins; [ coc-rust-analyzer ];
        coc.settings = {
          "rust-analyzer.server.path" = "${cfg.toolchainPackage}/bin/rust-analyzer";
        };
      };
    })
  ];
}
