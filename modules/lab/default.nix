# Desktop security / OSINT lab — nixpkgs tools, NM VPN for HTB/THM, optional local vuln apps.
{ config, lib, ... }:
let
  cfg = config.lab;
  captureOn = cfg.enable && cfg.capture.enable;

  mkTarget =
    description: hostPortDefault: containerPort:
    {
      enable = lib.mkEnableOption description;
      port = lib.mkOption {
        type = lib.types.port;
        default = hostPortDefault;
        description = "Host port on 127.0.0.1 (container :${toString containerPort})";
      };
      autoStart = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
in
{
  imports = [
    ./tools.nix
    ./vpn.nix
    ./targets.nix
  ];

  options.lab = {
    enable = lib.mkEnableOption ''
      security-lab CLI tools from nixpkgs (see tools.nix). Practice web apps in Docker are
      controlled separately under lab.targets.*
    '';

    capture = {
      enable = lib.mkEnableOption ''
        Wireshark and dumpcap so you can sniff traffic during labs; adds your user to the
        wireshark group (no root needed for capture)
      '';
    };

    vpn = {
      enable = lib.mkEnableOption ''
        Hack The Box / TryHackMe-style VPNs via NetworkManager (OpenVPN plugin plus firewall
        settings that keep tun routes working)
      '';
    };

    targets = {
      dvwa = mkTarget "DVWA (Damn Vulnerable Web Application)" 8901 80;
      juiceShop = mkTarget "OWASP Juice Shop" 3000 3000;
      webgoat = mkTarget "OWASP WebGoat" 8902 8080;
      vampi = mkTarget "VAmPI (vulnerable REST API)" 8903 5000;
      bwapp = mkTarget "bWAPP (buggy web app)" 8904 80;
      mutillidae = mkTarget "OWASP Mutillidae II (NOWASP)" 8905 80;
      dvga = mkTarget "Damn Vulnerable GraphQL Application (DVGA)" 8906 5013;
      dvna = mkTarget "Damn Vulnerable Node Application (DVNA)" 8907 9090;
      vulnerableApp = mkTarget "OWASP VulnerableApp (PHP)" 8908 80;
      wrongSecrets = mkTarget "OWASP WrongSecrets" 8909 8080;
      railsgoat = mkTarget "OWASP RailsGoat" 8910 3000;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      lab.capture.enable = lib.mkDefault true;
      lab.vpn.enable = lib.mkDefault true;
    })
    (lib.mkIf captureOn {
      programs.wireshark = {
        enable = true;
        dumpcap.enable = true;
      };
      users.users.${config.my.username}.extraGroups = [ "wireshark" ];
    })
  ];
}
