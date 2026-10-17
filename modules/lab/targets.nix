# Local practice apps — 127.0.0.1 only; systemctl start docker-lab-<name>
{ config, lib, ... }:
let
  cfg = config.lab;
  t = cfg.targets;

  bind = hostPort: containerPort:
    "127.0.0.1:${toString hostPort}:${toString containerPort}";

  # name → oci-containers attr when enabled
  spec = [
    # https://github.com/digininja/DVWA — PHP/MySQL web app; SQLi, XSS, CSRF, file upload, command injection by difficulty level.
    {
      name = "lab-dvwa";
      on = t.dvwa.enable;
      image = "vulnerables/web-dvwa";
      ports = [ (bind t.dvwa.port 80) ];
      autoStart = t.dvwa.autoStart;
    }
    # https://github.com/juice-shop/juice-shop — Modern OWASP Top 10 SPA; gamified CTF-style challenges and scoreboard.
    {
      name = "lab-juiceshop";
      on = t.juiceShop.enable;
      image = "bkimminich/juice-shop";
      ports = [ (bind t.juiceShop.port 3000) ];
      autoStart = t.juiceShop.autoStart;
    }
    # https://github.com/WebGoat/WebGoat — Step-by-step lessons (injection, auth, crypto, etc.) with hints in the UI.
    {
      name = "lab-webgoat";
      on = t.webgoat.enable;
      image = "webgoat/webgoat";
      ports = [ (bind t.webgoat.port 8080) ];
      autoStart = t.webgoat.autoStart;
    }
    # https://github.com/erev0s/VAmPI — Intentionally vulnerable REST API; BOLA/IDOR, weak auth, mass assignment.
    {
      name = "lab-vampi";
      on = t.vampi.enable;
      image = "erev0s/vampi";
      ports = [ (bind t.vampi.port 5000) ];
      autoStart = t.vampi.autoStart;
    }
    # https://github.com/lmoroz/bWAPP — ITSecGames bWAPP; 100+ vuln types (XSS, SQLi, CSRF, LDAP, file upload, etc.). Upstream: http://www.itsecgames.com/
    {
      name = "lab-bwapp";
      on = t.bwapp.enable;
      image = "raesene/bwapp";
      ports = [ (bind t.bwapp.port 80) ];
      autoStart = t.bwapp.autoStart;
    }
    # https://github.com/webpwnized/mutillidae — OWASP Mutillidae II; adjustable security levels, broad OWASP coverage.
    {
      name = "lab-mutillidae";
      on = t.mutillidae.enable;
      image = "citizenstig/nowasp";
      ports = [ (bind t.mutillidae.port 80) ];
      autoStart = t.mutillidae.autoStart;
    }
    # https://github.com/dolevf/Damn-Vulnerable-GraphQL-Application — GraphQL introspection, injection, and authorization flaws.
    {
      name = "lab-dvga";
      on = t.dvga.enable;
      image = "dolevf/dvga";
      ports = [ (bind t.dvga.port 5013) ];
      autoStart = t.dvga.autoStart;
    }
    # https://github.com/appsecco/dvna — Damn Vulnerable Node Application; Node/Express API security mistakes.
    {
      name = "lab-dvna";
      on = t.dvna.enable;
      image = "appsecco/dvna";
      ports = [ (bind t.dvna.port 9090) ];
      autoStart = t.dvna.autoStart;
    }
    # https://github.com/SasanLabs/VulnerableApp — OWASP VulnerableApp (PHP); command injection, XSS, JWT, SSRF-style lessons.
    {
      name = "lab-vulnerableapp";
      on = t.vulnerableApp.enable;
      image = "sasanlabs/owasp-vulnerableapp-php";
      ports = [ (bind t.vulnerableApp.port 80) ];
      autoStart = t.vulnerableApp.autoStart;
    }
    # https://github.com/OWASP/wrongsecrets — Find secrets in env, config, and cloud-style misconfigurations (not classic web vulns only).
    {
      name = "lab-wrongsecrets";
      on = t.wrongSecrets.enable;
      image = "owasp/wrongsecrets";
      ports = [ (bind t.wrongSecrets.port 8080) ];
      autoStart = t.wrongSecrets.autoStart;
    }
    # https://github.com/OWASP/railsgoat — Ruby on Rails app with deliberate flaws for secure-coding and exploitation practice.
    {
      name = "lab-railsgoat";
      on = t.railsgoat.enable;
      image = "owasp/railsgoat";
      ports = [ (bind t.railsgoat.port 3000) ];
      autoStart = t.railsgoat.autoStart;
    }
  ];

  containers = lib.listToAttrs (
    map (
      s:
      {
        inherit (s) name;
        value = {
          inherit (s) image ports autoStart;
        };
      }
    ) (lib.filter (s: s.on) spec)
  );
in
{
  config = lib.mkIf (cfg.enable && containers != { }) {
    virtualisation.oci-containers.containers = containers;
  };
}
