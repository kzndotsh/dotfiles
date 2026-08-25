{ config, identity, ... }:
{
  services.authelia.instances.main = {
    enable = true;
    secrets = {
      jwtSecretFile = config.sops.secrets."authelia-jwt-secret".path;
      sessionSecretFile = config.sops.secrets."authelia-session-secret".path;
      storageEncryptionKeyFile = config.sops.secrets."authelia-storage-encryption-key".path;
    };
    settings = {
      theme = "dark";
      default_2fa_method = "totp";
      server.address = "tcp://127.0.0.1:9091";
      log = { level = "error"; format = "json"; };
      totp = {
        issuer = identity.domain;
        algorithm = "SHA1";
        digits = 6;
        period = 30;
      };
      webauthn = {
        disable = false;
        display_name = identity.domain;
      };
      authentication_backend.file.path = config.sops.templates."authelia-users.yaml".path;
      password_policy.zxcvbn = { enabled = true; min_score = 3; };
      access_control = {
        default_policy = "deny";
        rules = [
          { domain = identity.fqdn "auth"; policy = "bypass"; }
          { domain = "*.${identity.domain}"; policy = "one_factor"; subject = [ "group:admins" ]; }
        ];
      };
      session = {
        cookies = [{
          inherit (identity) domain;
          authelia_url = "https://${identity.fqdn "auth"}";
          inactivity = "15 minutes";
          expiration = "1 hour";
          remember_me = "1 month";
        }];
      };
      regulation = {
        max_retries = 3;
        find_time = "2 minutes";
        ban_time = "5 minutes";
      };
      storage.local.path = "/var/lib/authelia-main/db.sqlite3";
      notifier.filesystem.filename = "/var/lib/authelia-main/notifications.txt";
    };
  };

  environment.etc."fail2ban/filter.d/authelia.conf".text = ''
    [Definition]
    failregex = ^.*Unsuccessful 1FA authentication attempt by user .*remote_ip="?<HOST>"?.*$
    ignoreregex =
    journalmatch = _SYSTEMD_UNIT=authelia-main.service
  '';
}
