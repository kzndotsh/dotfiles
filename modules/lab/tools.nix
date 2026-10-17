# Flat nixpkgs list for lab.enable — edit this file to add or drop tools.
{ config, lib, pkgs, ... }:
let
  cfg = config.lab;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # wordlists
      seclists

      # osint
      bbot
      sn0int
      amass
      subfinder
      theharvester
      sherlock
      h8mail
      asn

      # web
      burpsuite
      mitmproxy
      ffuf
      feroxbuster
      nuclei
      nuclei-templates
      gobuster
      sqlmap
      nikto
      testssl

      # network
      nmap
      masscan
      tcpdump
      netcat
      socat
      proxychains-ng
      chisel
      sshuttle

      # active directory
      # netexec pins python312; anyio 4.14.2 TLS tests fail there — skip checks for netexec's closure only
      (pkgs.extend (_: prev: {
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (_: pyprev: lib.optionalAttrs (pyprev.python.pythonVersion == "3.12") {
            anyio = pyprev.anyio.overridePythonAttrs { doCheck = false; };
          })
        ];
      })).netexec
      responder
      enum4linux-ng
      evil-winrm
      bloodhound-py

      # passwords
      hashcat
      hashcat-utils
      john
      thc-hydra

      # binary / reversing
      gdb
      gef
      pwntools
      radare2

      # wireless / mitm on lan
      aircrack-ng
      bettercap

      # exploitation / misc
      metasploit
      exploitdb
    ];

    environment.sessionVariables = {
      NUCLEI_TEMPLATES = "${pkgs.nuclei-templates}/share/nuclei-templates";
    };
  };
}
