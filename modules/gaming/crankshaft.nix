# KraXen72 Steam overlay (flake package wrap of the AppImage).
# https://github.com/KraXen72/crankshaft
# Derivation: packages/crankshaft/
{ config, lib, pkgs, self, ... }:
let
  cfg = config.gaming;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.crankshaft
    ];
  };
}
