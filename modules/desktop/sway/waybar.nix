# Waybar status bar — Tokyo Night palette, matching sway client.* and swaylock colors.
{ pkgs, ... }:
let
  # amdgpu sysfs → waybar JSON (text = busy %, tooltip = clocks/VRAM/temps/power/fan)
  gpuStatus = pkgs.writeShellScript "waybar-gpu" ''
    dev=$(dirname "$(echo /sys/class/drm/card*/device/gpu_busy_percent | cut -d' ' -f1)")
    hw=$(echo "$dev"/hwmon/hwmon*)
    r() { cat "$1" 2>/dev/null || echo 0; }
    busy=$(r "$dev/gpu_busy_percent")
    used=$(( $(r "$dev/mem_info_vram_used") / 1048576 ))
    total=$(( $(r "$dev/mem_info_vram_total") / 1048576 ))
    tip="Load: $busy%\\nVRAM: $used / $total MiB"
    tip="$tip\\nCore: $(( $(r "$hw/freq1_input") / 1000000 )) MHz  Mem: $(( $(r "$hw/freq2_input") / 1000000 )) MHz"
    tip="$tip\\nEdge: $(( $(r "$hw/temp1_input") / 1000 ))°C  Junction: $(( $(r "$hw/temp2_input") / 1000 ))°C  Mem: $(( $(r "$hw/temp3_input") / 1000 ))°C"
    tip="$tip\\nPower: $(( $(r "$hw/power1_average") / 1000000 )) / $(( $(r "$hw/power1_cap") / 1000000 )) W  Fan: $(r "$hw/fan1_input") RPM"
    printf '{"text":"G %s%%","tooltip":"%s"}\n' "$busy" "$tip"
  '';
in
{
  environment.etc."xdg/waybar/config.jsonc".text = builtins.toJSON {
    position = "bottom";
    height = 24;
    modules-left = [ "sway/workspaces" ];
    modules-center = [ "mpris" ];
    modules-right = [ "custom/gpu" "cpu" "memory" "pulseaudio" "pulseaudio#input" "custom/notifications" "tray" "clock" ];

    "sway/workspaces" = {
      disable-scroll = true;
      all-outputs = false;
    };

    mpris = {
      format = "<span font_family='JetBrainsMono Nerd Font Mono'>{status_icon}</span>  {title} - {artist}";
      status-icons = {
        playing = "󰐊";
        paused = "󰏤";
        stopped = "󰓛";
      };
      max-length = 40;
    };

    "custom/gpu" = {
      exec = "${gpuStatus}";
      return-type = "json";
      interval = 2;
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
      font-weight: normal;
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

    #custom-gpu, #cpu, #memory, #pulseaudio, #custom-notifications, #tray, #clock, #mpris {
      padding: 0 8px;
    }

    #custom-notifications {
      font-size: 18px;
    }
  '';

  # Waybar reads ~/.config/waybar first (XDG). Symlink to /etc so a leftover local file can't shadow NixOS.
  system.userActivationScripts.waybar-link.text = ''
    mkdir -p $HOME/.config/waybar
    ln -sfn /etc/xdg/waybar/config.jsonc $HOME/.config/waybar/config.jsonc
    ln -sfn /etc/xdg/waybar/style.css $HOME/.config/waybar/style.css
  '';
}
