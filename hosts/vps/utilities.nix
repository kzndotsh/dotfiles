{ config, identity, lib, ... }:
let
  want = name: (identity.vpsDns or null) == null || builtins.elem name identity.vpsDns;
in
{
  services.wastebin = lib.mkIf (want "wastebin") {
    enable = true;
    settings = {
      WASTEBIN_ADDRESS_PORT = "127.0.0.1:3200";
      WASTEBIN_BASE_URL = "https://${identity.fqdn "paste"}";
      WASTEBIN_TITLE = "paste";
    };
  };

  services.zipline = lib.mkIf (want "zipline") {
    enable = true;
    settings = {
      CORE_PORT = 3100;
      CORE_HOSTNAME = "0.0.0.0";
      DATASOURCE_TYPE = "local";
      DATASOURCE_LOCAL_DIRECTORY = "/var/lib/zipline/uploads";
    };
  };

  systemd.services.zipline.serviceConfig.EnvironmentFile =
    lib.mkIf (want "zipline") config.sops.templates."zipline.env".path;
}
