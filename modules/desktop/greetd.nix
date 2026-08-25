{ pkgs, lib, config, self, ... }:
let
  sessionsDir = "${config.services.displayManager.sessionData.desktops}/share";
in
{
  services.greetd.settings = {
    default_session.command = lib.mkForce (builtins.concatStringsSep " " [
      "env"
      "GDK_SCALE=2"
      "XDG_DATA_DIRS=${sessionsDir}"
      "${pkgs.dbus}/bin/dbus-run-session"
      "${pkgs.cage}/bin/cage -s -d -mlast --"
      "${lib.getExe config.services.displayManager.regreet.package}"
    ]);
  };

  services.displayManager.regreet = {
    enable = true;
    theme.name = "Tokyonight-Dark";
    font = {
      name = "Inter Nerd Font";
      size = 14;
      package = pkgs.inter-nerdfont;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "catppuccin-mocha-blue-cursors";
      package = pkgs.catppuccin-cursors.mochaBlue;
    };
    settings = {
      background = {
        path = "${self + /assets/wallpaper.png}";
        fit = "Cover";
      };
      GTK.application_prefer_dark_theme = true;
      appearance.greeting_msg = "Welcome back!";
    };
  };
}
