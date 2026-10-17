# HTB / TryHackMe — import .ovpn via nm-applet or nmcli; creds live in ~/.secrets/lab/.
{ config, lib, pkgs, ... }:
let
  cfg = config.lab;
  vpnOn = cfg.enable && cfg.vpn.enable;
in
{
  config = lib.mkIf vpnOn {
    networking.networkmanager.plugins = lib.mkAfter [ pkgs.networkmanager-openvpn ];
    networking.firewall.checkReversePath = lib.mkDefault "loose";
  };
}
