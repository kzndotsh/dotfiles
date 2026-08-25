# /etc/sway/config.d/20-windows.conf — for_window / no_focus / inhibit_idle.
# app_id = Wayland, class/window_role/window_type = XWayland (man 5 CRITERIA).
# Dump properties: swaymsg -t get_tree (Arch wiki Floating windows).
# Comma between commands keeps criteria; semicolon resets (man 5).
# inhibit_idle focus = no lock while that window is focused (RuneLite/DAWs).
{
  environment.etc."sway/config.d/20-windows.conf".text = ''
    # Floating / dialogs
    for_window [app_id="org.gajim.Gajim" title="^(?!Gajim$)"] floating enable
    for_window [app_id="vivaldi-stable" title=".*Settings.*"] floating enable
    for_window [app_id="chromium" title=".*Settings.*"] floating enable
    for_window [app_id="google-chrome" title=".*Settings.*"] floating enable
    for_window [app_id="brave-browser" title=".*Settings.*"] floating enable
    for_window [app_id="system-config-printer"] floating enable
    for_window [app_id="gnome-calculator"] floating enable
    for_window [app_id="keepassxc"] floating enable
    for_window [app_id="pavucontrol"] floating enable
    for_window [app_id="pwvucontrol"] floating enable
    for_window [app_id="vlc"] floating enable
    for_window [app_id="nm-connection-editor$"] floating enable
    for_window [app_id="simple-scan"] floating enable
    for_window [app_id="gnome-(calendar|calculator|power-statistics|control-center)"] floating enable
    for_window [app_id="xdg-desktop-portal-gtk"] floating enable
    for_window [title="^Open File$"] floating enable

    # Steam & gaming
    # allow_tearing: window + output + max_render_time off. Fullscreen only.
    for_window [app_id="steam"] floating enable border normal
    for_window [class="(?i)^steam$" title="^Steam$"] floating enable border normal
    for_window [class="(?i)^steam$" title="^Steam$"] resize set 1280 800
    for_window [class="^Steam$" title="^Friends"] floating enable
    for_window [title="Friends List"] floating enable border normal
    for_window [title="Friends List"] resize set 320 720
    for_window [class="^Steam$" title="Steam - News"] floating enable
    for_window [class="^Steam$" title=".* - Chat"] floating enable
    for_window [class="^Steam$" title="^Settings"] floating enable
    for_window [class="^Steam$" title=".* - event started"] floating enable
    for_window [class="^Steam$" title="^Steam - Self Updater"] floating enable
    for_window [class="^Steam$" title="^Screenshot Uploader"] floating enable
    for_window [class="(?i)^steam$" title="^Steam Guard.*"] floating enable border normal
    for_window [class="(?i)^steam$" title=".* CD key"] floating enable border normal
    for_window [title="^Steam Keyboard"] floating enable
    for_window [title="Special Offers"] floating enable border normal
    for_window [title="Steam - Browser"] floating enable border normal
    for_window [title="notificationtoasts.*"] floating enable, no_focus
    for_window [title="^None$"] floating enable, no_focus
    for_window [title="Wine System Tray"] move scratchpad
    for_window [title="Steam Big Picture Mode"] fullscreen enable
    for_window [title="Steam Big Picture Mode"] border none
    for_window [class="steam_app_*"] fullscreen enable
    for_window [class="steam_app_*"] border none
    for_window [class="steam_app_*"] allow_tearing yes
    for_window [class="gamescope"] fullscreen enable
    for_window [class="gamescope"] border none
    for_window [class="gamescope"] allow_tearing yes
    for_window [title="Steam Big Picture Mode"] inhibit_idle fullscreen
    for_window [class="steam_app_*"] inhibit_idle fullscreen
    for_window [class="gamescope"] inhibit_idle fullscreen
    for_window [app_id="vlc"] inhibit_idle fullscreen
    for_window [app_id="mpv"] inhibit_idle fullscreen

    # RuneLite (XWayland / AWT)
    # Swing tooltips spawn as win0/win1 and steal focus.
    # https://github.com/runelite/runelite/issues/19076
    # Request Focus → Force does not work on Sway. swaync runelite-focus + $mod+Ctrl+grave.
    no_focus [class="net-runelite-client-RuneLite" title="win"]
    for_window [class="net-runelite-client-RuneLite" title="win"] floating enable, border none
    for_window [class="net-runelite-client-RuneLite"] inhibit_idle focus

    # Music production DAWs
    # class=Wine floats every Wine window; FL Studio rule after that tiles the DAW.
    for_window [class="bitwig-studio"] inhibit_idle focus
    for_window [class="bitwig-studio" title="^(?!Bitwig Studio$)"] floating enable
    for_window [class="REAPER"] inhibit_idle focus
    for_window [class="REAPER" title="^(?!REAPER v)"] floating enable
    for_window [app_id="ardour-*"] inhibit_idle focus
    for_window [app_id="lmms"] inhibit_idle focus
    for_window [app_id="org.zrythm.Zrythm"] inhibit_idle focus
    for_window [class="Wine"] floating enable
    for_window [class="Wine" title="FL Studio"] floating disable, inhibit_idle focus
    for_window [class="yabridge-host*"] floating enable
    for_window [app_id="org.hydrogenmusic.Hydrogen"] floating enable
    for_window [app_id="Carla2"] floating enable

    # Dialog roles / pinentry / bluetooth
    for_window [window_role="pop-up"] floating enable
    for_window [window_role="bubble"] floating enable
    for_window [window_role="task_dialog"] floating enable
    for_window [window_role="Preferences"] floating enable
    for_window [window_type="dialog"] floating enable
    for_window [window_type="menu"] floating enable
    for_window [title="About Mozilla Firefox"] floating enable
    for_window [title="Firefox Preferences"] floating enable
    for_window [window_role="About"] floating enable
    for_window [window_role="Organizer"] floating enable
    for_window [window_role="page-info"] floating enable
    for_window [window_role="toolbox"] floating enable
    for_window [window_role="webconsole"] floating enable
    for_window [app_id="org.gnome.FileRoller"] floating enable
    for_window [app_id="imv"] floating enable
    for_window [class="(?i)1password"] floating enable
    for_window [app_id="pinentry"] floating enable
    for_window [class="(?i)pinentry"] floating enable
    for_window [app_id="blueman"] floating enable
    for_window [app_id="io.github.kaii_lb.Overskride"] floating enable
    for_window [app_id="io.github.ebonjaeger.bluejay"] floating enable
    for_window [class="^(Yad|Zenity|zenity)$"] floating enable
    for_window [app_id="(?i)polkit"] floating enable

    # Zoom
    # Workplace: as_toolbar + title ^Zoom Workplace$ float; Licensed account tiled.
    # app_id/class=zoom stay for the X11 client.
    for_window [app_id="zoom"] floating disable
    for_window [app_id="zoom"] border normal
    for_window [app_id="zoom"] inhibit_idle fullscreen
    for_window [class="zoom"] floating enable
    for_window [class="zoom"] resize set 1200 800
    for_window [class="zoom"] move position center
    for_window [title="Select a window or an application"] floating enable
    for_window [title="Select a window or an application"] move position center
    for_window [app_id="Zoom Workplace" title="^as_toolbar$"] floating enable
    for_window [app_id="Zoom Workplace" title="^Zoom Workplace$"] floating enable
    for_window [app_id="Zoom Workplace" title="^Zoom Workplace - Licensed account$"] floating disable

    no_focus [app_id="waybar"]
    for_window [app_id="waybar" floating] {
        move position cursor
        move down 60px
    }
  '';
}
