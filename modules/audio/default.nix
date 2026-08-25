{ ... }:
{
  imports = [
    ./pipewire.nix
    ./wireplumber.nix
  ];

  # rtkit lets PipeWire grab SCHED_FIFO when RLIMIT_RTPRIO is too low.
  # Music and gaming modules load the actual RT rules in WirePlumber.
  security.rtkit.enable = true;

  # PAM limits for the realtime group (see user.nix). rtprio 98 leaves 99 for IRQ threads.
  users.groups.realtime = {};
  security.pam.loginLimits = [
    { domain = "@realtime"; type = "-"; item = "rtprio"; value = "98"; }
    { domain = "@realtime"; type = "-"; item = "memlock"; value = "unlimited"; }
    { domain = "@realtime"; type = "-"; item = "nice"; value = "-11"; }
  ];
}
