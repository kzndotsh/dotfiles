# swayr + fuzzel. Papirus here is launcher icons only — GTK is TokyoNight-SE.
# https://git.sr.ht/~tsdh/swayr
{ pkgs, ... }:
let
  papirus = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark";
  hicolor = "${pkgs.hicolor-icon-theme}/share/icons/hicolor";
in
{
  environment.etc."xdg/swayr/config.toml".text = ''
    [menu]
    executable = "fuzzel"
    args = [
      "--dmenu",
      "--prompt=󰖲  {prompt}",
      "--width=44",
      "--lines=16",
      "--line-height=26",
      "--icon-theme=Papirus-Dark",
    ]

    [format]
    # {app_name} is Wayland app_id (com.foo.bar), not the .desktop Name — use title instead
    window_format = "{urgency_start}{title:{:.58}}{urgency_end}\u0000icon\u001f{app_icon}"
    workspace_format = "󰧨 {name} [{layout}]"
    container_format = "󰆍 {marks}"
    indent = "    "
    urgency_start = "▸ "
    urgency_end = ""
    icon_dirs = [
      "${hicolor}/scalable/apps",
      "${hicolor}/128x128/apps",
      "${hicolor}/64x64/apps",
      "${hicolor}/48x48/apps",
      "${hicolor}/32x32/apps",
      "${papirus}/64x64/apps",
      "${papirus}/48x48/apps",
      "${papirus}/32x32/apps",
      "${pkgs.papirus-icon-theme}/share/pixmaps",
      "/run/current-system/sw/share/icons/hicolor/scalable/apps",
      "/run/current-system/sw/share/icons/hicolor/128x128/apps",
      "/run/current-system/sw/share/icons/hicolor/64x64/apps",
      "/run/current-system/sw/share/icons/hicolor/48x48/apps",
      "/run/current-system/sw/share/pixmaps",
      "${pkgs.vesktop}/share/icons/hicolor/48x48/apps",
      "${pkgs.vesktop}/share/icons/hicolor/128x128/apps",
    ]

    [focus]
    lockin_delay = 750
  '';

  system.userActivationScripts.swayr-link.text = ''
    mkdir -p $HOME/.config/swayr
    ln -sfn /etc/xdg/swayr/config.toml $HOME/.config/swayr/config.toml
  '';
}
