# Waybar — Tokyo Night, same palette as sway client.* / swaylock.
# https://github.com/Alexays/Waybar/wiki
{ pkgs, ... }:
{
  environment.etc."xdg/waybar/config.jsonc".text = builtins.toJSON {
    position = "bottom";
    height = 24;
    modules-left = [ "sway/workspaces" ];
    modules-center = [ "mpris" ];
    modules-right = [ "cpu" "memory" "pulseaudio" "pulseaudio#input" "custom/notifications" "tray" "clock" ];

    "sway/workspaces" = {
      disable-scroll = true;
      all-outputs = false;
    };

    mpris = {
      format = "{title} - {artist}";
      format-paused = "{title} - {artist} (paused)";
      max-length = 40;
    };

    cpu = {
      format = "C {usage}%";
      interval = 1;
    };

    memory = {
      format = "M {percentage}%";
    };

    pulseaudio = {
      format = "O {volume}%";
      format-muted = "O muted";
      on-click = "${pkgs.pwvucontrol}/bin/pwvucontrol";
    };

    "pulseaudio#input" = {
      format = "{format_source}";
      format-source = "I {volume}%";
      format-source-muted = "I muted";
    };

    "custom/notifications" = {
      exec = "swaync-client -swb";
      return-type = "json";
      format = "{icon} {0}";
      format-icons = {
        notification = "󰂞";
        none = "󰂜";
        dnd-notification = "󰂛";
        dnd-none = "󰪑";
      };
      on-click = "swaync-client -t -sw";
      escape = true;
    };

    tray = {
      spacing = 8;
    };

    clock = {
      format = "{:%a %b %d  %I:%M %p}";
      tooltip-format = "{:%Y-%m-%d}";
    };
  };

  environment.etc."xdg/waybar/style.css".text = ''
    * {
      border: none;
      border-radius: 0;
      font-family: "Inter Nerd Font", monospace;
      font-size: 13px;
    }

    window#waybar {
      background-color: #1a1b26;
      color: #c0caf5;
    }

    #workspaces button {
      padding: 0 6px;
      color: #c0caf5;
      background: transparent;
      border: none;
      box-shadow: none;
    }

    #workspaces button:hover {
      background: #292e42;
    }

    #workspaces button.visible,
    #workspaces button.focused {
      background: #292e42;
    }

    #workspaces button.urgent {
      background: #db4b4b;
    }

    #cpu, #memory, #pulseaudio, #custom-notifications, #tray, #clock, #mpris {
      padding: 0 8px;
    }

    #custom-notifications {
      font-size: 16px;
    }

    #clock {
      font-weight: bold;
    }
  '';

  # Waybar reads ~/.config/waybar first (XDG). Pin it to /etc so a leftover
  # local file cannot shadow NixOS.
  system.userActivationScripts.waybar-link.text = ''
    mkdir -p $HOME/.config/waybar
    ln -sfn /etc/xdg/waybar/config.jsonc $HOME/.config/waybar/config.jsonc
    ln -sfn /etc/xdg/waybar/style.css $HOME/.config/waybar/style.css
  '';
}
