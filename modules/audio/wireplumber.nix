_:
{
  # WirePlumber drop-ins live in /etc/wireplumber/wireplumber.conf.d/ — filenames sort alphanumerically.
  services.pipewire.wireplumber.extraConfig = {
    # Higher priority.session wins default sink/source. Keep sinks below ~1500 or their
    # monitor steals default-source; FiiO at 2000 is fine because Yeti input is 2500.
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

    # Yeti X: skip WirePlumber's "best profile" — it often picks a multichannel/IEC958 mix we don't want.
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

    # Mute onboard and HDMI audio (alsa_card.pci-*). This also silences GPU HDMI output.
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

    # WirePlumber suspends idle USB nodes after 5s by default — that causes pops on wake.
    # Complements boot/udev.nix setting power/control=on for the FiiO and Yeti.
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

    # Default capture volume when WirePlumber has no saved route (0.8 = 80% linear).
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
