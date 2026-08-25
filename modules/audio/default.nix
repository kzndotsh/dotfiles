{ ... }:
{
  imports = [
    ./pipewire.nix
    ./wireplumber.nix
  ];

  # ─── Realtime ───
  # PipeWire asks rtkit (or the realtime portal) for SCHED_FIFO on data threads
  # when RLIMIT_RTPRIO is not already high enough.
  # https://docs.pipewire.org/page_module_rt.html
  # https://wiki.nixos.org/wiki/PipeWire
  security.rtkit.enable = true;

  # PAM rlimits for members of `realtime` (user.nix). Matches Arch
  # realtime-privileges: rtprio 98 (leave 99 for IRQ threads), memlock, nice -11.
  # These apply to login sessions, not systemd services (limits.conf(5)).
  # libpipewire-module-rt itself is *not* here — music 97-music-rt / gaming 98-gaming-rt.
  # https://man7.org/linux/man-pages/man5/limits.conf.5.html
  # https://wiki.archlinux.org/title/Professional_audio
  users.groups.realtime = {};
  security.pam.loginLimits = [
    { domain = "@realtime"; type = "-"; item = "rtprio"; value = "98"; }
    { domain = "@realtime"; type = "-"; item = "memlock"; value = "unlimited"; }
    { domain = "@realtime"; type = "-"; item = "nice"; value = "-11"; }
  ];
}
