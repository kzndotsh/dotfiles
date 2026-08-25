{ pkgs, config, ... }:
let
  filesCred = "${config.my.secretsDir}/cloudflared/files.json";
in
{
  systemd = {
    tmpfiles.rules = [
      "d ${config.my.secretsDir}/cloudflared 0700 ${config.my.username} users -"
    ];

    user.services.copyparty = {
      description = "Copyparty file server";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        # Credentials live in ~/.secrets/copyparty.env (not in git) because the Cloudflare tunnel exposes this port.
        EnvironmentFile = "${config.my.secretsDir}/copyparty.env";
        ExecStart = "${pkgs.copyparty}/bin/copyparty -a $COPYPARTY_ACCOUNT -v ${config.my.home}/Public::rw,${config.my.username} -e2dsa --qr -z";
        Restart = "on-failure";
      };
    };

    user.services.cloudflared-files = {
      description = "Cloudflare Tunnel - files";
      after = [ "copyparty.service" ];
      wantedBy = [ "default.target" ];
      unitConfig.ConditionPathExists = filesCred;
      serviceConfig = {
        ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate --credentials-file ${filesCred} run --url http://127.0.0.1:3923 files";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
