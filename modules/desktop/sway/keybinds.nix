# /etc/sway/config.d/10-keybinds.conf
# $mod is Mod1 (Alt). Stock config.in uses Mod4 + foot/wmenu.
# --locked: run even on the lock screen (man 5 bindsym). Without it, volume
# keys die while locked. --no-repeat: hold Return must not spawn a terminal storm.
{
  environment.etc."sway/config.d/10-keybinds.conf".text = ''
    # ─── Launchers / clipboard ───
    bindsym --no-repeat $mod+Return exec $term
    bindsym $mod+d exec $menu
    bindsym $mod+grave exec swayr switch-window
    bindsym $mod+backslash exec swayr switch-window
    bindsym $mod+Shift+grave exec swayr switch-workspace
    bindsym $mod+Ctrl+grave exec swayr switch-to-urgent-or-lru-window
    bindsym $mod+c exec wl-color-picker clipboard
    bindsym $mod+Shift+n exec swaync-client -t -sw
    bindsym $mod+period exec bemoji -t -c
    bindsym $mod+Shift+v exec cliphist list | fuzzel --dmenu | cliphist decode | wl-copy

    # ─── Screenshots ───
    bindsym Print exec grim - | wl-copy
    bindsym --release Control+Print exec grim -g "$(slurp)" -t ppm - | satty --filename - --fullscreen --copy-command wl-copy --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png
    bindsym $mod+Shift+s exec ~/.local/bin/zipline-upload
    bindsym $mod+Shift+Print exec grim -g "$(slurp)" - | wl-copy

    # ─── Focus / workspaces ───
    bindsym $mod+Left focus left
    bindsym $mod+Down focus down
    bindsym $mod+Up focus up
    bindsym $mod+Right focus right

    bindsym $mod+Tab workspace next
    bindsym $mod+Shift+Tab workspace prev
    bindsym $mod+Ctrl+Left workspace prev
    bindsym $mod+Ctrl+Right workspace next

    bindsym $mod+1 workspace number 1
    bindsym $mod+2 workspace number 2
    bindsym $mod+3 workspace number 3
    bindsym $mod+4 workspace number 4
    bindsym $mod+5 workspace number 5
    bindsym $mod+6 workspace number 6
    bindsym $mod+7 workspace number 7
    bindsym $mod+8 workspace number 8
    bindsym $mod+9 workspace number 9
    bindsym $mod+0 workspace number 10

    bindsym $mod+Shift+Left move left
    bindsym $mod+Shift+Down move down
    bindsym $mod+Shift+Up move up
    bindsym $mod+Shift+Right move right

    bindsym $mod+Shift+1 move container to workspace number 1
    bindsym $mod+Shift+2 move container to workspace number 2
    bindsym $mod+Shift+3 move container to workspace number 3
    bindsym $mod+Shift+4 move container to workspace number 4
    bindsym $mod+Shift+5 move container to workspace number 5
    bindsym $mod+Shift+6 move container to workspace number 6
    bindsym $mod+Shift+7 move container to workspace number 7
    bindsym $mod+Shift+8 move container to workspace number 8
    bindsym $mod+Shift+9 move container to workspace number 9
    bindsym $mod+Shift+0 move container to workspace number 10

    # ─── Layout ───
    # move left; move right: apply layout to this container, not the parent (i3 idiom).
    bindsym $mod+h splith
    bindsym $mod+v splitv
    bindsym $mod+s move left; move right; layout stacking
    bindsym $mod+w move left; move right; layout tabbed
    bindsym $mod+e move left; move right; layout toggle split
    bindsym $mod+f fullscreen
    bindsym $mod+Shift+f focus parent; fullscreen; focus child
    bindsym $mod+Shift+space floating toggle
    bindsym $mod+space focus mode_toggle
    bindsym $mod+a focus parent

    bindsym $mod+Shift+q kill
    bindsym $mod+Shift+l exec $lock
    bindsym $mod+Shift+r reload
    bindsym $mod+Shift+e exec swaynag -t warning -m 'Exit sway?' -B 'Yes' 'swaymsg exit'

    # pactl → PipeWire pulse shim. --locked from config.in / Arch wiki.
    bindsym --locked XF86AudioRaiseVolume exec pactl set-sink-volume @DEFAULT_SINK@ +5%
    bindsym --locked XF86AudioLowerVolume exec pactl set-sink-volume @DEFAULT_SINK@ -5%
    bindsym --locked XF86AudioMute exec pactl set-sink-mute @DEFAULT_SINK@ toggle
    bindsym --locked XF86AudioMicMute exec pactl set-source-mute @DEFAULT_SOURCE@ toggle
    bindsym --locked XF86AudioPlay exec playerctl play-pause
    bindsym --locked XF86AudioNext exec playerctl next
    bindsym --locked XF86AudioPrev exec playerctl previous
  '';
}
