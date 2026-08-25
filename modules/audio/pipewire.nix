_:
{
  # PulseAudio and PipeWire's pulse shim cannot both own the socket — keep PA off.
  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    # 32-bit ALSA shim for Steam and Wine.
    alsa.support32Bit = true;

    extraConfig.pipewire."99-custom" = {
      "context.properties" = {
        # 48 kHz suits video and games; 44.1 kHz is listed so the graph can switch when idle.
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [ 44100 48000 ];
        # ~10.7 ms buffer at 48 kHz (512/48000). Gaming RT keeps this; music does not touch quantum.
        "default.clock.quantum" = 512;
        # Stop games from pulling the floor down to 32-sample quanta.
        "default.clock.min-quantum" = 256;
        "default.clock.max-quantum" = 2048;
      };
    };
  };
}
