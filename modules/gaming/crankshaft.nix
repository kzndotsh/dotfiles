# KraXen72's Steam overlay, wrapped from the upstream AppImage (packages/crankshaft/).
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
