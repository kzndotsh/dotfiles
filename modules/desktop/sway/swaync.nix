# SwayNotificationCenter. RuneLite's "Request Focus → Force" does not work on Sway (runelite#19076).
{ lib, pkgs, ... }:
let
  swaymsg = lib.getExe' pkgs.sway "swaymsg";
  # RuneLite can't force-focus on Sway, so we focus it when a notification arrives instead.
  # Must be a path-only exec: swaync wraps as `/bin/sh -c "<exec>"`, so nested quotes in an
  # inline swaymsg criteria string break the shell parse.
  runeliteFocus = pkgs.writeShellScript "runelite-focus" ''
    exec ${swaymsg} '[class="net-runelite-client-RuneLite"] focus'
  '';
  config = {
    "$schema" = "${pkgs.swaynotificationcenter}/etc/xdg/swaync/configSchema.json";
    ignore-gtk-theme = true;
    positionX = "right";
    positionY = "top";
    layer = "overlay";
    control-center-layer = "top";
    layer-shell = true;
    layer-shell-cover-screen = true;
    cssPriority = "user";
    control-center-margin-top = 0;
    control-center-margin-bottom = 0;
    control-center-margin-right = 0;
    control-center-margin-left = 0;
    notification-2fa-action = true;
    notification-inline-replies = false;
    notification-body-image-height = 100;
    notification-body-image-width = 200;
    timeout = 10;
    timeout-low = 5;
    timeout-critical = 0;
    fit-to-screen = true;
    relative-timestamps = true;
    control-center-width = 500;
    control-center-height = 600;
    notification-window-width = 500;
    keyboard-shortcuts = true;
    notification-grouping = true;
    image-visibility = "when-available";
    transition-time = 200;
    hide-on-clear = false;
    hide-on-action = true;
    text-empty = "No Notifications";
    script-fail-notify = true;
    scripts = {
      runelite-focus = {
        app-name = "RuneLite";
        run-on = "receive";
        exec = "${runeliteFocus}";
      };
    };
    widgets = [
      "inhibitors"
      "title"
      "dnd"
      "notifications"
    ];
    widget-config = {
      notifications = {
        vexpand = true;
      };
      inhibitors = {
        text = "Inhibitors";
        button-text = "Clear All";
        clear-all-button = true;
      };
      title = {
        text = "Notifications";
        clear-all-button = true;
        button-text = "Clear All";
      };
      dnd = {
        text = "Do Not Disturb";
      };
    };
  };
in
{
  environment.etc."xdg/swaync/config.json".text = builtins.toJSON config;

  environment.etc."xdg/swaync/style.css".text = ''
    @define-color base #1a1b26;
    @define-color mantle #16161e;
    @define-color surface0 #292e42;
    @define-color surface1 #3b4261;
    @define-color surface2 #414868;
    @define-color text #c0caf5;
    @define-color subtext0 #a9b1d6;
    @define-color subtext1 #9aa5ce;
    @define-color blue #7aa2f7;
    @define-color sapphire #7dcfff;
    @define-color red #f7768e;
    @define-color maroon #db4b4b;
    @define-color pink #bb9af7;
    @define-color yellow #e0af68;

    * {
      all: unset;
      font-size: 14px;
      font-family: "Inter Nerd Font";
      transition: 200ms;
    }

    trough highlight {
      background: @text;
    }

    scale {
      margin: 0 7px;
    }

    scale trough {
      margin: 0rem 1rem;
      min-height: 8px;
      min-width: 70px;
      border-radius: 12.6px;
    }

    trough slider {
      margin: -10px;
      border-radius: 12.6px;
      box-shadow: 0 0 2px rgba(0, 0, 0, 0.8);
      transition: all 0.2s ease;
      background-color: @blue;
    }

    trough slider:hover {
      box-shadow: 0 0 2px rgba(0, 0, 0, 0.8), 0 0 8px @blue;
    }

    trough {
      background-color: @surface0;
    }

    .notification-background {
      box-shadow: inset 0 0 0 1px @surface1;
      border-radius: 12.6px;
      margin: 18px;
      background: @mantle;
      color: @text;
      padding: 0;
    }

    .notification-background .notification {
      padding: 7px;
      border-radius: 12.6px;
    }

    .notification-background .notification.critical {
      box-shadow: inset 0 0 7px 0 @red;
    }

    .notification .notification-content {
      margin: 7px;
    }

    .notification .notification-content overlay {
      margin: 4px;
    }

    .notification-content .summary {
      color: @text;
    }

    .notification-content .time {
      color: @subtext0;
    }

    .notification-content .body {
      color: @subtext1;
    }

    .notification > *:last-child > * {
      min-height: 3.4em;
    }

    .notification-background .close-button {
      margin: 7px;
      padding: 2px;
      border-radius: 6.3px;
      color: @base;
      background-color: @red;
    }

    .notification-background .close-button:hover {
      background-color: @maroon;
    }

    .notification-background .close-button:active {
      background-color: @pink;
    }

    .notification .notification-action {
      border-radius: 7px;
      color: @text;
      box-shadow: inset 0 0 0 1px @surface1;
      margin: 4px;
      padding: 8px;
      font-size: 0.2rem;
    }

    .notification .notification-action {
      background-color: @surface0;
    }

    .notification .notification-action:hover {
      background-color: @surface1;
    }

    .notification .notification-action:active {
      background-color: @surface2;
    }

    .notification.critical progress {
      background-color: @red;
    }

    .notification.low progress,
    .notification.normal progress {
      background-color: @blue;
    }

    .notification progress,
    .notification trough,
    .notification progressbar {
      border-radius: 12.6px;
      padding: 3px 0;
    }

    .control-center {
      box-shadow: inset 0 0 0 1px @surface0;
      border-radius: 12.6px;
      background-color: @base;
      color: @text;
      padding: 14px;
    }

    .control-center .notification-background {
      border-radius: 7px;
      box-shadow: inset 0 0 0 1px @surface1;
      margin: 4px 10px;
    }

    .control-center .notification-background .notification {
      border-radius: 7px;
    }

    .control-center .notification-background .notification.low {
      opacity: 0.8;
    }

    .control-center .widget-title > label {
      color: @text;
      font-size: 1.3em;
    }

    .control-center .widget-title button {
      border-radius: 7px;
      color: @text;
      background-color: @surface0;
      box-shadow: inset 0 0 0 1px @surface1;
      padding: 8px;
    }

    .control-center .widget-title button:hover {
      background-color: @surface1;
    }

    .control-center .widget-title button:active {
      background-color: @surface2;
    }

    .control-center .notification-group {
      margin-top: 10px;
    }

    scrollbar slider {
      margin: -3px;
      opacity: 0.8;
    }

    scrollbar trough {
      margin: 2px 0;
    }

    .widget-dnd {
      margin-top: 5px;
      border-radius: 8px;
      font-size: 1.1rem;
    }

    .widget-dnd > switch {
      font-size: initial;
      border-radius: 8px;
      background: @surface0;
      box-shadow: none;
    }

    .widget-dnd > switch:checked {
      background: @blue;
    }

    .widget-dnd > switch slider {
      background: @surface1;
      border-radius: 8px;
    }

    .widget-mpris-player {
      background: @surface0;
      border-radius: 12.6px;
      color: @text;
    }

    .widget-mpris-title {
      font-size: 1.2rem;
      color: @text;
    }

    .widget-mpris-subtitle {
      font-size: 1rem;
      color: @subtext1;
    }

    .widget-mpris button {
      border-radius: 12.6px;
      color: @text;
      margin: 0 5px;
      padding: 2px;
    }

    .widget-mpris button:hover {
      background-color: @surface0;
    }

    .widget-mpris button:active {
      background-color: @surface1;
    }

    .widget-volume {
      padding: 1rem 0;
    }

    .widget-volume label {
      color: @sapphire;
      padding: 0 1rem;
    }

    .widget-volume trough highlight {
      background: @sapphire;
    }

    .widget-backlight trough highlight {
      background: @yellow;
    }

    .widget-backlight label {
      font-size: 1.5rem;
      color: @yellow;
    }

    .image {
      padding-right: 0.5rem;
    }
  '';

  system.userActivationScripts.swaync-link.text = ''
    mkdir -p $HOME/.config/swaync
    ln -sfn /etc/xdg/swaync/config.json $HOME/.config/swaync/config.json
    ln -sfn /etc/xdg/swaync/style.css $HOME/.config/swaync/style.css
  '';

  # Don't auto-start swaync with graphical-session.target — D-Bus activation via waybar's
  # swaync-client handles startup instead, avoiding "already running" race failures.
  systemd.user.services.swaync = {
    wantedBy = lib.mkForce [];
    serviceConfig = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${pkgs.swaynotificationcenter}/bin/swaync";
      ExecReload = "${pkgs.swaynotificationcenter}/bin/swaync-client --reload-config ; ${pkgs.swaynotificationcenter}/bin/swaync-client --reload-css";
      Restart = "on-failure";
    };
    unitConfig = {
      Description = "Swaync notification daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
  };
}
