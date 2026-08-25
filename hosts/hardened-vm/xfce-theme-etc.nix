# Declarative XFCE and LightDM theme files for Tokyo Night.
_:
{
  environment.etc = {
    "xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <channel name="xsettings" version="1.0">
        <property name="Net" type="empty">
          <property name="ThemeName" type="string" value="Tokyonight-Dark"/>
          <property name="IconThemeName" type="string" value="Papirus-Dark"/>
        </property>
        <property name="Gtk" type="empty">
          <property name="FontName" type="string" value="Inter Nerd Font 10"/>
          <property name="MonospaceFontName" type="string" value="JetBrainsMono Nerd Font Mono 10"/>
          <property name="CursorThemeName" type="string" value="catppuccin-mocha-blue-cursors"/>
          <property name="CursorThemeSize" type="int" value="24"/>
        </property>
      </channel>
    '';

    "xdg/xfce4/terminal/terminalrc".text = ''
      [Configuration]
      ColorBackground=#1a1b26
      ColorForeground=#c0caf5
      ColorSelectionBackground=#283457
      ColorSelection=#c0caf5
      ColorPalette=#15161e;#f7768e;#9ece6a;#e0af68;#7aa2f7;#bb9af7;#7dcfff;#a9b1d6;#414868;#f7768e;#9ece6a;#e0af68;#7aa2f7;#bb9af7;#7dcfff;#c0caf5
      FontName=JetBrainsMono Nerd Font Mono 11
      MiscAlwaysShowTabs=FALSE
      MiscBordersDefault=FALSE
      ScrollingBar=TERMINAL_SCROLLBAR_NONE
    '';

    "xdg/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <channel name="xfwm4" version="1.0">
        <property name="general" type="empty">
          <property name="use_compositing" type="bool" value="true"/>
          <property name="unredirect_overlays" type="bool" value="true"/>
          <property name="cycle_draw_frame" type="bool" value="false"/>
          <property name="cycle_raise" type="bool" value="false"/>
          <property name="box_move" type="bool" value="false"/>
          <property name="box_resize" type="bool" value="false"/>
          <property name="easy_click" type="string" value="None"/>
          <property name="titleless_maximize" type="bool" value="true"/>
          <property name="title_alignment" type="string" value="center"/>
          <property name="title_font" type="string" value="Inter Nerd Font 9"/>
          <property name="button_layout" type="string" value="|MC"/>
          <property name="snap_to_border" type="bool" value="true"/>
          <property name="snap_to_windows" type="bool" value="true"/>
          <property name="focus_model" type="string" value="click"/>
          <property name="double_click_action" type="string" value="maximize"/>
          <property name="frame_border_top" type="int" value="0"/>
        </property>
      </channel>
    '';

    "xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <channel name="xfce4-panel" version="1.0">
        <property name="panels" type="array">
          <value type="int" value="1"/>
          <property name="panel-1" type="empty">
            <property name="position" type="string" value="p=8;x=0;y=0"/>
            <property name="size" type="uint" value="28"/>
            <property name="autohide-behavior" type="uint" value="2"/>
            <property name="background-style" type="uint" value="1"/>
            <property name="background-rgba" type="array">
              <value type="double" value="0.101961"/>
              <value type="double" value="0.105882"/>
              <value type="double" value="0.149020"/>
              <value type="double" value="0.900000"/>
            </property>
          </property>
        </property>
      </channel>
    '';

    "xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <channel name="xfce4-desktop" version="1.0">
        <property name="desktop-icons" type="empty">
          <property name="style" type="int" value="0"/>
        </property>
      </channel>
    '';

    "xdg/gtk-3.0/gtk.css".text = ''
      .xfce4-panel {
        background: #1a1b26;
        color: #c0caf5;
        font-family: 'Inter Nerd Font';
        font-size: 11px;
        border: none;
      }
      .xfce4-panel button {
        color: #c0caf5;
        border: none;
        border-radius: 4px;
        padding: 2px 6px;
        margin: 2px;
      }
      .xfce4-panel button:hover {
        background: #283457;
        color: #7aa2f7;
      }
      .xfce4-panel button:checked {
        background: #283457;
        color: #7aa2f7;
        border-bottom: 2px solid #7aa2f7;
      }
      .xfce4-panel .tasklist .toggle {
        border-radius: 4px;
        margin: 3px;
        padding: 3px;
      }
      .xfce4-panel .tasklist .toggle:checked {
        background: #283457;
        border-bottom: 2px solid #73daca;
      }
      #clock-button {
        color: #565f89;
        font-weight: bold;
      }
    '';
  };
}
