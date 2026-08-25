# /etc/sway/config.d/30-autostart.conf
# exec = once per session. exec_always = every reload (gsettings, env, xrdb).
{ pkgs, ... }:
{
  environment.etc."sway/config.d/30-autostart.conf".text = ''
    exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
    # Must match modules/desktop/theme.nix dconf (TokyoNight-SE, not Papirus).
    exec_always gsettings set org.gnome.desktop.interface gtk-theme 'Tokyonight-Dark'
    exec_always gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    exec_always gsettings set org.gnome.desktop.interface icon-theme 'TokyoNight-SE'
    exec_always gsettings set org.gnome.desktop.interface cursor-theme 'catppuccin-mocha-blue-cursors'
    exec_always gsettings set org.gnome.desktop.interface cursor-size 24
    exec_always gsettings set org.gnome.desktop.interface font-name 'Inter Nerd Font 11'

    # https://github.com/ammernico/autotiling-rs — not exec_always (two copies fight).
    exec autotiling-rs
    exec nm-applet --indicator
    exec blueman-applet
    exec --no-startup-id swayrd
    exec --no-startup-id udiskie --tray

    # https://github.com/Linus789/wl-clip-persist  https://github.com/sentriz/cliphist
    exec wl-clip-persist --clipboard regular --all-mime-type-regex '.*'
    exec wl-paste --type text --watch cliphist store
    exec wl-paste --type image --watch cliphist store
    # X11 clipboard for XWayland (xclip is modules/packages).
    exec wl-paste --type image --watch xclip -selection clipboard -t image/png -i

    exec eval $(gnome-keyring-daemon --start --components=secrets)
    exec_always systemctl --user import-environment WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP SWAYSOCK I3SOCK XCURSOR_SIZE XCURSOR_THEME GNOME_KEYRING_CONTROL PATH XDG_DATA_DIRS XDG_RUNTIME_DIR XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME XDG_BIN_HOME CARGO_HOME RUSTUP_HOME
    exec_always dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP SWAYSOCK I3SOCK XCURSOR_SIZE XCURSOR_THEME GNOME_KEYRING_CONTROL PATH XDG_DATA_DIRS XDG_RUNTIME_DIR XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME XDG_BIN_HOME CARGO_HOME RUSTUP_HOME
    # Wine Xft: /etc/X11/Xresources from modules/wine.
    exec_always xrdb -load /etc/X11/Xresources
    exec systemctl --user start gvfs-udisks2-volume-monitor.service
    # Click offset if XWayland has no primary. Needs output pos 0 0.
    # Hotplug creates a new XWAYLANDn and drops primary.
    # https://wiki.archlinux.org/title/Sway#Mouse_not_working_in_WINE_applications
    exec_always sh -c 'OUT=$(xrandr 2>/dev/null | grep -m1 XWAYLAND | awk "{print \$1}"); [ -n "$OUT" ] && xrandr --output "$OUT" --primary'

    # -w: wait for each command. swaylock *must* -f/--daemonize or idle DPMS
    # never runs (swayidle blocked until unlock). Stock config.in uses -f.
    # inhibit_idle in 20-windows.conf skips games/DAWs while focused/fullscreen.
    # https://man.archlinux.org/man/swayidle.1
    exec swayidle -w \
      timeout 600 '$lock -f' \
      timeout 605 'swaymsg "output * power off"' \
      resume 'swaymsg "output * power on"' \
      before-sleep '$lock -f'
  '';
}
