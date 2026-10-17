# Kiro Crew — persistent agent workspace. Dashboard on 127.0.0.1:5476.
# Drives nixpkgs kiro-cli. State stays in ~/.kiro/crew (not the Nix store).
# Do not run `kirocrew service install` — that writes /etc/systemd outside Nix.
{ config, lib, pkgs, ... }:
let
  cfg = config.ai.kirocrew;
  pkg = pkgs.callPackage ../../packages/kirocrew { };
in
{
  options.ai.kirocrew = {
    enable = lib.mkEnableOption "Kiro Crew gateway (user service, loopback :5476)";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkg;
      description = "Kiro Crew package (pinned wheel in packages/kirocrew)";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 5476;
      description = "Loopback port for the dashboard and gateway API";
    };

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Start the user unit at login (wantedBy default.target)";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.user.services.kirocrew = {
      description = "Kiro Crew gateway";
      after = [ "network-online.target" ];
      wantedBy = lib.optionals cfg.autoStart [ "default.target" ];
      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} gateway --port ${toString cfg.port}";
        Restart = "on-failure";
        RestartSec = 5;
        WorkingDirectory = config.my.home;
      };
      # NixOS user units only get coreutils/findutils/grep/sed/systemd.
      # The gateway execs host tools by name (`git init`, `gh`, …). Give it
      # the system profile. /run/wrappers wins for setuid helpers. The
      # package wrapper still prefixes kiro-cli-unwrapped so the FHS bwrap
      # `kiro-cli` in the profile does not come first.
      path = [
        "/run/wrappers"
        "/run/current-system/sw"
      ];
    };
  };
}
