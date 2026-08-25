# Gaming Wine extras — Lutris / Heroic / Bottles / umu-launcher.
#
# Base wine (wine-tkg, winetricks, wineprefix-preparer): modules/wine/
# This file: launchers + FHS workarounds. `gaming.wine.enable` turns on `wine.enable`.
#
# umu-launcher = Proton-outside-Steam for Heroic/Lutris 0.5.20+:
#   https://github.com/Open-Wine-Components/umu-launcher
# Legendary CLI (package is `legendary-gl`, not `legendary`):
#   https://github.com/derrod/legendary
#
# Prefix deps (manual/Lutris/Heroic): corefonts, vcrun2022, d3dx9/d3dx11, dotnet48
#   WINEPREFIX=~/Games/mygame wineprefix-preparer   # DXVK + vkd3d (from modules/wine)
#   WINEPREFIX=~/Games/mygame winetricks vcrun2022 corefonts
#
# openldap: flaky i686 test017 broke Lutris/Bottles FHS from source
#   https://github.com/NixOS/nixpkgs/issues/513245  (closed; skip-test PRs exist)
# Do not use a global overlay (rebuilds half the system). Override buildFHSEnv
# inside the launcher only. Drop when `nixpkgs#lutris` is reliably cached.
#
# patool tests break on Python 3.14 (bzip2/lzma detection) — skip in Bottles only.
{ config, lib, pkgs, ... }:
let
  cfg = config.gaming;

  openldapFixedFHSEnv = args:
    pkgs.buildFHSEnv (args // {
      multiPkgs = envPkgs:
        let
          originalPkgs = args.multiPkgs envPkgs;
          customLdap = envPkgs.openldap.overrideAttrs (_: { doCheck = false; });
        in
        builtins.filter (p: (p.pname or "") != "openldap") originalPkgs ++ [ customLdap ];
    });

  bottlesPatched = let
    patoolFixed = pkgs.python3Packages.patool.overridePythonAttrs (_: { doCheck = false; });
    bottlesUnwrapped = pkgs.bottles-unwrapped.override {
      python3Packages = pkgs.python3Packages // { patool = patoolFixed; };
    };
  in pkgs.bottles.override {
    buildFHSEnv = openldapFixedFHSEnv;
    bottles-unwrapped = bottlesUnwrapped;
  };

  lutris = pkgs.lutris.override { buildFHSEnv = openldapFixedFHSEnv; };
  bottles = bottlesPatched;
  # Heroic uses steam.buildRuntimeEnv — no openldap FHS hook.
  heroic = pkgs.heroic.override {
    extraPkgs = pkgs': with pkgs'; [ gamescope gamemode mangohud ];
  };
in
{
  config = lib.mkIf cfg.enable {
    wine.enable = lib.mkIf cfg.wine.enable (lib.mkDefault true);

    environment.systemPackages = [
      pkgs.umu-launcher
      pkgs.legendary-gl
    ]
    ++ lib.optionals cfg.lutris.enable [ lutris ]
    ++ lib.optionals cfg.heroic.enable [ heroic ]
    ++ lib.optionals cfg.bottles.enable [ bottles ];
  };
}
