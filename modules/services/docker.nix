# Docker daemon for the desktop (via services/) and hardened VM (this file only).
# The VPS slim stack does not use Docker. oci-containers.backend = "docker" is set in modules/ai/default.nix
# because the NixOS default is podman. docker group membership is root-equivalent — set on the host in user.nix.
{
  virtualisation.docker = {
    enable = true;
    # Start the daemon at boot so --restart=always and oci-containers autoStart work.
    # With enableOnBoot = false you only get socket activation.
    enableOnBoot = true;
    # journald matches what we want; Docker Engine's own default is json-file.
    logDriver = "journald";
    autoPrune = {
      enable = true;
      dates = "weekly";
      # --all removes unused images too, not just dangling layers.
      flags = [ "--all" ];
    };
    # Docker has no default ulimit here; 65536 matches our PAM nofile limit.
    extraOptions = "--default-ulimit nofile=65536:65536";
    daemon.settings = {
      # userland-proxy is on by default (docker-proxy for published ports). Off = iptables only.
      userland-proxy = false;
      # live-restore keeps containers running across daemon restarts; incompatible with swarm.
      live-restore = true;
      # Pin Cloudflare DNS so containers skip host DoT and NetworkManager resolv.conf quirks.
      dns = [ "1.1.1.1" "1.0.0.1" ];
    };
  };
}
