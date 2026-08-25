# kiro-gateway — Anthropic/OpenAI-compatible proxy to Kiro (Amazon Q / CodeWhisperer).
# Always-on on 127.0.0.1:9000 (upstream listens on 0.0.0.0:8000 by default).
# https://github.com/jwadow/kiro-gateway
#
# Auth: PROXY_API_KEY in ~/.secrets/ai.env (KIRO_GATEWAY_API_KEY is a local alias).
# Credentials: ACCOUNT_SYSTEM=true stores ~/.config/kiro-gateway/credentials.json
# instead of a cwd-relative file that could land in the repo.
# kiro-cli DB path comes from ai.env (KIRO_CLI_DB_FILE).
{ pkgs, inputs, self, config, ... }:
let
  dataDir = "${config.my.home}/.config/kiro-gateway";
  aiEnvFile = "${config.my.secretsDir}/ai.env";

  kiroGatewayPkg = import (self + /packages/kiro-gateway) {
    inherit (pkgs) lib python3 runCommand writeShellApplication;
    kiroGatewaySrc = inputs.kiro-gateway;
  };

  kiroGatewayStart = pkgs.writeShellScript "kiro-gateway-start" ''
    set -a
    if [ -f ${aiEnvFile} ]; then . ${aiEnvFile}; fi
    set +a

    if [ -z "''${PROXY_API_KEY:-}" ] && [ -z "''${KIRO_GATEWAY_API_KEY:-}" ]; then
      echo "kiro-gateway: set PROXY_API_KEY or KIRO_GATEWAY_API_KEY in ${aiEnvFile}" >&2
      exit 1
    fi
    export PROXY_API_KEY="''${PROXY_API_KEY:-$KIRO_GATEWAY_API_KEY}"
    export ACCOUNTS_CONFIG_FILE="''${ACCOUNTS_CONFIG_FILE:-${dataDir}/credentials.json}"
    export ACCOUNTS_STATE_FILE="''${ACCOUNTS_STATE_FILE:-${dataDir}/state.json}"
    export ACCOUNT_SYSTEM="''${ACCOUNT_SYSTEM:-true}"

    exec ${kiroGatewayPkg}/bin/kiro-gateway --port 9000 --host 127.0.0.1
  '';
in
{
  systemd = {
    services.kiro-gateway = {
      description = "kiro-gateway — Anthropic-compatible proxy (port 9000)";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      restartTriggers = [ kiroGatewayPkg ];
      serviceConfig = {
        Type = "simple";
        User = config.my.username;
        Group = "users";
        EnvironmentFile = [ "-${aiEnvFile}" ];
        ExecStart = kiroGatewayStart;
        Restart = "on-failure";
        RestartSec = 5;
        # Missing API key (1) or empty credentials (3) — don't fail `nh os switch`.
        SuccessExitStatus = "1 3";
      };
    };

    tmpfiles.rules = [
      "d ${dataDir} 0700 ${config.my.username} users -"
      "d ${config.my.secretsDir}/cloudflared 0700 ${config.my.username} users -"
    ];

    # Named tunnel `kiro` → kiro.kzn.sh. Sync creds with `nix run .#vps-tunnels-sync`.
    user.services.cloudflared-kiro = {
      description = "Cloudflare Tunnel - kiro-gateway";
      after = [ "network-online.target" "kiro-gateway.service" ];
      wantedBy = [ "default.target" ];
      unitConfig.ConditionPathExists = "${config.my.secretsDir}/cloudflared/kiro.json";
      serviceConfig = {
        ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate --credentials-file ${config.my.secretsDir}/cloudflared/kiro.json run --url http://127.0.0.1:9000 kiro";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
