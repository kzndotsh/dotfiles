_:
{
  # SPA-JSON drop-ins under /etc/wireplumber/wireplumber.conf.d/ (single-instance).
  # Quote dotted keys. Filenames sort alphanumerically.
  # https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration/alsa.html
  # https://wiki.archlinux.org/title/WirePlumber
  services.pipewire.wireplumber.extraConfig = {
    # Default sink/source: higher priority.session wins.
    # Sources default ~1600–2000, sinks ~600–1000. WP: do not put a *sink*
    # above 1500 or its monitor can steal default-source — FiiO is 2000, but
    # Yeti input is 2500 so the mic still wins.
    "50-device-priority" = {
      "monitor.alsa.rules" = [
        {
          matches = [{ "node.name" = "~alsa_output.usb-FIIO*"; }];
          actions.update-props = {
            "priority.driver" = 2000;
            "priority.session" = 2000;
          };
        }
        {
          matches = [{ "node.name" = "~alsa_input.usb-Blue_Microphones*"; }];
          actions.update-props = {
            "priority.driver" = 2500;
            "priority.session" = 2500;
          };
        }
        {
          matches = [{ "node.name" = "~alsa_input.usb-EMEET*"; }];
          actions.update-props = {
            "priority.driver" = 1800;
            "priority.session" = 1800;
          };
        }
      ];
    };

    # Yeti X: skip WP "best profile" (often a multichannel/IEC958 mix).
    "52-yeti-profile" = {
      "monitor.alsa.rules" = [
        {
          matches = [{ "device.name" = "~alsa_card.usb-Blue_Microphones*"; }];
          actions.update-props = {
            "device.profile" = "input:analog-stereo";
          };
        }
      ];
    };

    # Onboard + HDMI (alsa_card.pci-*). Also kills GPU HDMI audio.
    "51-disable-devices" = {
      "monitor.alsa.rules" = [
        {
          matches = [{ "device.name" = "~alsa_card.pci-*"; }];
          actions.update-props = {
            "device.disabled" = true;
          };
        }
      ];
    };

    # Default suspend is 5s (pops when the USB DAC wakes). 0 = leave ALSA open.
    # Complements boot udev `power/control=on` on FiiO 1852:7022 / Yeti 046d:0aaf.
    # https://wiki.archlinux.org/title/PipeWire#Noticeable_audio_delay_or_audible_pop/crack_when_starting_playback
    "99-disable-suspend" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            { "node.name" = "~alsa_output.usb-*"; }
            { "node.name" = "~alsa_input.usb-*"; }
          ];
          actions.update-props = {
            "session.suspend-timeout-seconds" = 0;
          };
        }
      ];
    };

    # Default capture volume when no saved route volume exists (WP 0.5.14+).
    # 0.8 = 80% (linear). https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration/settings.html
    "53-yeti-volume" = {
      "monitor.alsa.rules" = [
        {
          matches = [{ "device.name" = "~alsa_card.usb-Blue_Microphones*"; }];
          actions.update-props = {
            "device.routes.default-source-volume" = 0.8;
          };
        }
      ];
    };
  };
}
