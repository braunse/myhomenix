{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.mine.dev.dlang;

in
{
  options = {
    mine.dev.dlang = {
      enable = mkEnableOption "D";
      enableLdc = mkEnableOption "LDC";
      enableGdc = mkEnableOption "GDC";
      enableDmd = mkEnableOption "DMD";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      mine.dev.dlang.enableLdc = mkDefault true;

      home.packages = [
        pkgs.dub
      ] ++ (optionals cfg.enableLdc [ pkgs.ldc ])
      ++ (optionals cfg.enableGdc [ pkgs.gdc ])
      ++ (optionals cfg.enableDmd [ pkgs.dmd ]);

      programs.neovim = {
        plugins =
          let
            removeDevDeps = orig-src: pkgs.runCommandNoCC "src.tgz" { buildInputs = [ pkgs.jq ]; } ''
              mkdir unpacked
              cd unpacked
              tar xzvf ${orig-src}
              mv package/package.json package/package.json.orig
              jq 'del(.devDependencies)' < package/package.json.orig > package/package.json
              tar czvf $out .
            '';
            coc-dlang-nodepkg = (pkgs.callPackage ./dlang/coc-dlang {
              nodejs = pkgs.nodejs-16_x;
            }).coc-dlang;
            coc-dlang-patched = coc-dlang-nodepkg.override {
              src = removeDevDeps coc-dlang-nodepkg.src;
              dontNpmInstall = true;
            };
            coc-dlang-vimPlugin = pkgs.vimUtils.buildVimPluginFrom2Nix rec {
              pname = "coc-dlang";
              inherit (coc-dlang-nodepkg) version meta;
              src = "${coc-dlang-patched}/lib/node_modules/${pname}";
            };
          in
          [ coc-dlang-vimPlugin ];
      };
    })
  ];
}
  
