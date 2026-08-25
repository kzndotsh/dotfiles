{ pkgs, config, lib, ... }:
let
  tokyonight-icons = pkgs.stdenvNoCC.mkDerivation {
    pname = "tokyo-night-icons";
    version = "0.2.0";

    src = pkgs.fetchurl {
      url = "https://github.com/ljmill/tokyo-night-icons/releases/download/v0.2.0/TokyoNight-SE.tar.bz2";
      sha256 = "sha256-s6aqdswMj8Vk7dlTD6gZAq3OlM1PrDodjvhAqsYRlqo=";
    };

    sourceRoot = ".";

    installPhase = ''
      mkdir -p $out/share/icons
      cp -r TokyoNight-SE $out/share/icons/
    '';

    meta = {
      description = "Beautiful icons themed in Tokyo Night";
      homepage = "https://github.com/ljmill/tokyo-night-icons";
      license = pkgs.lib.licenses.gpl3;
    };
  };

  tokyonight-kvantum = pkgs.fetchFromGitHub {
    owner = "0xsch1zo";
    repo = "Kvantum-Tokyo-Night";
    rev = "main";
    sha256 = "1979na97ifj9mdn2cn1dnhxrkqqxf4vcgyza3rhjbnb31a157k4r";
  };

  tokyonight-gtk-theme = pkgs.stdenvNoCC.mkDerivation {
    pname = "tokyonight-gtk-theme";
    version = "0-unstable-2025-10-23";

    src = pkgs.fetchFromGitHub {
      owner = "Fausto-Korpsvart";
      repo = "Tokyonight-GTK-Theme";
      rev = "master";
      sha256 = "sha256-7H2n9wTaW8Db1RejWK071ITV1j5KIuzfql0Tx9WT6zM=";
    };

    nativeBuildInputs = [ pkgs.sassc ];

    postUnpack = ''
      chmod -R u+w "$sourceRoot"
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/themes
      cd themes
      bash install.sh \
        --dest "$out/share/themes" \
        --name "Tokyonight" \
        --color dark
      runHook postInstall
    '';

    meta = {
      description = "GTK theme based on the Tokyo Night colour palette";
      homepage = "https://github.com/Fausto-Korpsvart/Tokyonight-GTK-Theme";
      license = lib.licenses.gpl3Plus;
    };
  };

  user = config.users.users.${config.my.username};
in
{
  # Make theme packages available system-wide so GTK can find them
  environment.systemPackages = [
    tokyonight-gtk-theme
    tokyonight-icons
    pkgs.papirus-icon-theme
    pkgs.gnome-themes-extra
    # Qt theming: qt5ct/qt6ct are the config tools; kvantum packages
    # are pulled in automatically by qt.style = "kvantum" below
    pkgs.libsForQt5.qt5ct
    pkgs.qt6Packages.qt6ct
    pkgs.qt6.qtwayland
  ];

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    XCURSOR_SIZE = "24";
    XCURSOR_THEME = "catppuccin-mocha-blue-cursors";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    # GTK_THEME is the fallback for GTK3 apps that ignore settings.ini;
    # GTK4/libadwaita reads dconf instead (set below via programs.dconf).
    GTK_THEME = "Tokyonight-Dark";
    SAL_USE_VCLPLUGIN = "gtk3";
  };

  # dconf is the correct mechanism for GTK4/libadwaita theming.
  # GTK4 apps ignore gtk-theme-name in settings.ini entirely.
  # Note: programs.dconf.enable is already set in sway/default.nix
  programs.dconf.profiles.user.databases = [{
    settings = {
      "org/gnome/desktop/interface" = {
        gtk-theme = "Tokyonight-Dark";
        icon-theme = "TokyoNight-SE";
        cursor-theme = "catppuccin-mocha-blue-cursors";
        cursor-size = lib.gvariant.mkInt32 24;
        color-scheme = "prefer-dark";
        font-name = "Inter Nerd Font 11";
      };
    };
  }];

  qt = {
    enable = true;
    # qt5ct handles Qt5, qt6ct handles Qt6. The NixOS qt module sets qt5ct;
    # we override QT_QPA_PLATFORMTHEME below to cover both.
    platformTheme = "qt5ct";
    style = "kvantum";
  };

  # Write correct per-user GTK3 config (GTK3 reads ~/.config/gtk-3.0/settings.ini,
  # NOT /etc/xdg/gtk-3.0/settings.ini which the old environment.etc approach used).
  system.userActivationScripts = {
    gtk3-settings.text = ''
      mkdir -p ${user.home}/.config/gtk-3.0
      cat > ${user.home}/.config/gtk-3.0/settings.ini << 'EOF'
      [Settings]
      gtk-theme-name=Tokyonight-Dark
      gtk-application-prefer-dark-theme=1
      gtk-icon-theme-name=TokyoNight-SE
      gtk-cursor-theme-name=catppuccin-mocha-blue-cursors
      gtk-cursor-theme-size=24
      gtk-font-name=Inter Nerd Font 11
      EOF
      # Suppress window drop shadows on popups (prevents double borders)
      echo '.popup decoration { margin: 0; }' > ${user.home}/.config/gtk-3.0/gtk.css
    '';

    gtk4-settings.text = ''
      mkdir -p ${user.home}/.config/gtk-4.0
      cat > ${user.home}/.config/gtk-4.0/settings.ini << 'EOF'
      [Settings]
      gtk-application-prefer-dark-theme=1
      gtk-icon-theme-name=TokyoNight-SE
      gtk-cursor-theme-name=catppuccin-mocha-blue-cursors
      gtk-cursor-theme-size=24
      gtk-font-name=Inter Nerd Font 11
      EOF
      echo '.popup decoration { margin: 0; }' > ${user.home}/.config/gtk-4.0/gtk.css
    '';

    kvantum.text = ''
      mkdir -p ${user.home}/.config/Kvantum
      ln -sfn ${tokyonight-kvantum}/Kvantum-Tokyo-Night ${user.home}/.config/Kvantum/Kvantum-Tokyo-Night
      cat > ${user.home}/.config/Kvantum/kvantum.kvconfig << EOF
      [General]
      theme=Kvantum-Tokyo-Night
      EOF
    '';

    qt5ct-config.text = ''
      mkdir -p ${user.home}/.config/qt5ct
      cat > ${user.home}/.config/qt5ct/qt5ct.conf << 'EOF'
      [Appearance]
      style=kvantum
      icon_theme=TokyoNight-SE
      custom_palette=false
      standard_dialogs=default
      EOF
    '';

    qt6ct-config.text = ''
      mkdir -p ${user.home}/.config/qt6ct
      cat > ${user.home}/.config/qt6ct/qt6ct.conf << 'EOF'
      [Appearance]
      style=kvantum
      icon_theme=TokyoNight-SE
      custom_palette=false
      standard_dialogs=default
      EOF
    '';

    xresources.text = ''
      mkdir -p ${user.home}/.config/X11
      cat > ${user.home}/.config/X11/xresources << 'EOF'
      Xft.dpi: 96

      ! TokyoNight colors
      *background: #1a1b26
      *foreground: #c0caf5
      *color0: #15161e
      *color1: #f7768e
      *color2: #9ece6a
      *color3: #e0af68
      *color4: #7aa2f7
      *color5: #bb9af7
      *color6: #7dcfff
      *color7: #a9b1d6
      *color8: #414868
      *color9: #f7768e
      *color10: #9ece6a
      *color11: #e0af68
      *color12: #7aa2f7
      *color13: #bb9af7
      *color14: #7dcfff
      *color15: #c0caf5
      EOF
    '';
  };
}
