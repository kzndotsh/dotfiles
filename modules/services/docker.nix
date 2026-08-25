# Docker daemon — desktop (via services/) and hardened-vm (imports this file only).
# VPS does not use this module (slim kzn stack has no Docker).
# oci-containers.backend = "docker" is set in modules/ai/default.nix
# (NixOS default is podman). https://wiki.nixos.org/wiki/Docker
# Daemon JSON: https://docs.docker.com/reference/cli/dockerd/#daemon-configuration-file
# docker group is root-equivalent — membership is on the host (user.nix / VM user).
{
  virtualisation.docker = {
    enable = true;
    # NixOS default true. Required for --restart=always / oci-containers autoStart.
    # false = socket activation only.
    enableOnBoot = true;
    # NixOS default journald (Docker Engine default is json-file).
    logDriver = "journald";
    autoPrune = {
      # NixOS default false. Timer runs `docker system prune -f`.
      enable = true;
      # NixOS default weekly.
      dates = "weekly";
      # NixOS default []. --all also drops unused (non-dangling) images.
      # https://docs.docker.com/reference/cli/docker/system/prune/
      flags = [ "--all" ];
    };
    # Official default-ulimit is unset (inherit dockerd). nofile 65536 matches PAM.
    extraOptions = "--default-ulimit nofile=65536:65536";
    daemon.settings = {
      # Official default true (docker-proxy for published ports). false = iptables only.
      userland-proxy = false;
      # Official default false (dockerd stop kills containers). Incompatible with swarm.
      # https://docs.docker.com/engine/daemon/live-restore/
      live-restore = true;
      # Official default [] = host resolv.conf. Pin CF so containers skip host DoT/NM.
      dns = [ "1.1.1.1" "1.0.0.1" ];
    };
  };
}
