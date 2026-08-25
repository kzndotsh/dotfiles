_:
{
  # PulseAudio and PipeWire's pulse shim cannot both own the socket.
  # NixOS default is already false; pin so a host cannot re-enable PA.
  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    # 32-bit ALSA for Steam/Wine. NixOS default false.
    alsa.support32Bit = true;

    # Drop-in /etc/pipewire/pipewire.conf.d/99-custom.conf
    # https://docs.pipewire.org/page_man_pipewire_conf_5.html
    # https://wiki.archlinux.org/title/PipeWire#Changing_the_default_sample_rate
    extraConfig.pipewire."99-custom" = {
      "context.properties" = {
        # Graph rate. PipeWire default 48000 (video/games). CD is 44100.
        "default.clock.rate" = 48000;
        # Empty default = only `rate`. Non-empty: switch the graph when idle so
        # a 44.1 kHz stream can play without resample (DAC must support it).
        # Disabled upstream by default (kernel / Bluetooth issues).
        "default.clock.allowed-rates" = [ 44100 48000 ];
        # Latency ≈ quantum/rate. Default quantum 1024 → ~21 ms @ 48 kHz.
        # 512 → ~10.7 ms. Gaming RT keeps this; music does not change quantum.
        "default.clock.quantum" = 512;
        # Default min 32 / max 8192. Floor raised so games cannot pull 32.
        "default.clock.min-quantum" = 256;
        "default.clock.max-quantum" = 2048;
      };
    };
  };
}
