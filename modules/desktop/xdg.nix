# MIME defaults and session environment — desktop only (via desktop/). Do not import on the VM.
# xdg.mime.enable is already true by default on NixOS.
# XDG_BIN_HOME is not in the Base Directory spec, but Sway imports it anyway for ~/.local/bin.
# PDFs use pkgs.zathura (with-plugins, mupdf) plus /etc/zathurarc — there is no programs.zathura option.
{ lib, pkgs, ... }:
let
  archiveHandler = "org.gnome.FileRoller.desktop";
  archiveTypes = [
    "application/zip"
    "application/x-zip-compressed"
    "application/x-7z-compressed"
    "application/x-rar-compressed"
    "application/x-rar"
    "application/vnd.rar"
    "application/gzip"
    "application/x-gzip"
    "application/x-bzip"
    "application/x-bzip2"
    "application/x-xz"
    "application/x-tar"
    "application/x-compressed-tar"
    "application/x-gzip-compressed-tar"
    "application/x-bzip-compressed-tar"
    "application/x-xz-compressed-tar"
    "application/x-lzma"
    "application/x-lzma-compressed-tar"
    "application/x-tgz"
    "application/zstd"
    "application/x-zstd"
    "application/x-stuffit"
    "application/x-arj"
    "application/vnd.ms-cab-compressed"
  ];

  mpvHandler = "mpv.desktop";
  audioTypes = [
    "audio/x-vorbis+ogg"
    "audio/aac"
    "audio/x-aac"
    "audio/vnd.dolby.heaac.1"
    "audio/vnd.dolby.heaac.2"
    "audio/aiff"
    "audio/x-aiff"
    "audio/m4a"
    "audio/x-m4a"
    "audio/mp1"
    "audio/x-mp1"
    "audio/mp2"
    "audio/x-mp2"
    "audio/mp3"
    "audio/x-mp3"
    "audio/mpeg"
    "audio/mpeg2"
    "audio/mpeg3"
    "audio/mpegurl"
    "audio/x-mpegurl"
    "audio/mpg"
    "audio/x-mpg"
    "audio/rn-mpeg"
    "audio/musepack"
    "audio/x-musepack"
    "audio/ogg"
    "audio/scpls"
    "audio/x-scpls"
    "audio/vnd.rn-realaudio"
    "audio/wav"
    "audio/x-pn-wav"
    "audio/x-pn-windows-pcm"
    "audio/x-realaudio"
    "audio/x-pn-realaudio"
    "audio/x-ms-wma"
    "audio/x-pls"
    "audio/x-wav"
    "audio/x-ms-asf"
    "audio/x-matroska"
    "audio/webm"
    "audio/vorbis"
    "audio/x-vorbis"
    "audio/x-shorten"
    "audio/x-ape"
    "audio/x-wavpack"
    "audio/x-tta"
    "audio/AMR"
    "audio/ac3"
    "audio/eac3"
    "audio/amr-wb"
    "audio/flac"
    "audio/mp4"
    "audio/x-pn-au"
    "audio/3gpp"
    "audio/3gpp2"
    "audio/dv"
    "audio/opus"
    "audio/vnd.dts"
    "audio/vnd.dts.hd"
    "audio/x-adpcm"
    "audio/m3u"
    "audio/vnd.wave"
  ];
  videoTypes = [
    "video/mp4"
    "video/quicktime"
    "video/x-matroska"
    "video/mpeg"
    "video/ogg"
    "video/x-ogm+ogg"
    "video/x-mpeg2"
    "video/x-mpeg3"
    "video/mp4v-es"
    "video/x-m4v"
    "video/divx"
    "video/vnd.divx"
    "video/msvideo"
    "video/x-msvideo"
    "video/vnd.rn-realvideo"
    "video/x-ms-afs"
    "video/x-ms-asf"
    "video/x-ms-wmv"
    "video/x-ms-wmx"
    "video/x-ms-wvxvideo"
    "video/x-avi"
    "video/avi"
    "video/x-flic"
    "video/fli"
    "video/x-flc"
    "video/flv"
    "video/x-flv"
    "video/x-theora"
    "video/x-theora+ogg"
    "video/mkv"
    "video/webm"
    "video/x-ogm"
    "video/mp2t"
    "video/vnd.mpegurl"
    "video/3gp"
    "video/3gpp"
    "video/3gpp2"
    "video/dv"
    "video/vnd.avi"
    "application/vnd.rn-realmedia"
  ];
in
{
  environment = {
    systemPackages = [ pkgs.zathura ];

    etc."zathurarc".text = ''
      set notification-error-bg "#f7768e"
      set notification-error-fg "#c0caf5"
      set notification-warning-bg "#e0af68"
      set notification-warning-fg "#414868"
      set notification-bg "#1a1b26"
      set notification-fg "#c0caf5"
      set completion-bg "#1a1b26"
      set completion-fg "#a9b1d6"
      set completion-group-bg "#1a1b26"
      set completion-group-fg "#a9b1d6"
      set completion-highlight-bg "#414868"
      set completion-highlight-fg "#c0caf5"
      set index-bg "#1a1b26"
      set index-fg "#c0caf5"
      set index-active-bg "#414868"
      set index-active-fg "#c0caf5"
      set inputbar-bg "#1a1b26"
      set inputbar-fg "#c0caf5"
      set statusbar-bg "#1a1b26"
      set statusbar-fg "#c0caf5"
      set highlight-color "#e0af68"
      set highlight-active-color "#9ece6a"
      set default-bg "#1a1b26"
      set default-fg "#c0caf5"
      set render-loading true
      set render-loading-fg "#1a1b26"
      set render-loading-bg "#c0caf5"
      set recolor-lightcolor "#1a1b26"
      set recolor-darkcolor "#c0caf5"
      set recolor true
      set recolor-keephue true
    '';

    sessionVariables = {
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_BIN_HOME = "$HOME/.local/bin";
      PATH = [
        "$HOME/.local/share/mise/shims"
        "$HOME/.local/bin"
        "$HOME/.local/share/npm/bin"
        "$HOME/.local/share/pnpm/bin"
        "$HOME/.local/share/bun/bin"
        "$HOME/.local/share/python/bin"
      ];

      TERMINAL = "ghostty";
      EDITOR = "micro";
      VISUAL = "micro";
      BROWSER = "firefox";

      SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";

      # mise defaults all_compile=true on NixOS (deprecated, removed in 2027.8.0). We compile from cache instead.
      MISE_ALL_COMPILE = "false";
      MISE_NODE_COMPILE = "false";
      MISE_PYTHON_COMPILE = "false";

      # Use $HOME/… not $XDG_DATA_HOME/… so paths stay stable if XDG_* isn't set yet at login.
      CARGO_HOME = "$HOME/.local/share/cargo";
      RUSTUP_HOME = "$HOME/.local/share/rustup";

      NPM_CONFIG_USERCONFIG = "$HOME/.config/npm/npmrc";
      NPM_CONFIG_PREFIX = "$HOME/.local/share/npm";
      NODE_REPL_HISTORY = "$HOME/.local/share/node_repl_history";

      PNPM_HOME = "$HOME/.local/share/pnpm";
      BUN_INSTALL = "$HOME/.local/share/bun";

      GOPATH = "$HOME/.local/share/go";
      GOMODCACHE = "$HOME/.cache/go/mod";

      DOCKER_CONFIG = "$HOME/.config/docker";

      PYTHON_HISTORY = "$HOME/.local/state/python_history";
      PYTHONPYCACHEPREFIX = "$HOME/.cache/python";
      PYTHONUSERBASE = "$HOME/.local/share/python";
      PIP_CONFIG_FILE = "$HOME/.config/pip/pip.conf";
      # mise owns global python (conf.d/python.toml); uv must not fetch a second interpreter tree.
      UV_PYTHON_DOWNLOADS = "never";
      # uv reads XDG_* — cache ~/.cache/uv, data ~/.local/share/uv, config ~/.config/uv; tool bins → XDG_BIN_HOME.

      GNUPGHOME = "$HOME/.local/share/gnupg";
      WGETRC = "$HOME/.config/wgetrc";
      CUDA_CACHE_PATH = "$HOME/.cache/nv";
      LESSHISTFILE = "$HOME/.local/state/lesshst";
      HISTFILE = "$HOME/.local/state/bash/history";

      GST_PLUGIN_SYSTEM_PATH_1_0 = "/run/current-system/sw/lib/gstreamer-1.0";
    };
  };

  xdg = {
    # micro.desktop is Terminal=true — GLib/Nautilus needs xdg.terminal-exec to spawn Ghostty.
    # Without it, "Open with Micro" is a no-op (there is no gnome-terminal on this host).
    terminal-exec = {
      enable = true;
      settings = {
        default = [ "com.mitchellh.ghostty.desktop" ];
        sway = [ "com.mitchellh.ghostty.desktop" ];
      };
    };

    mime = {
      enable = true;
      defaultApplications = {
      "inode/directory" = "org.gnome.Nautilus.desktop";
      "image/png" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/webp" = "imv.desktop";
      "image/tiff" = "imv.desktop";
      "image/bmp" = "imv.desktop";
      "image/svg+xml" = "imv.desktop";
      "text/html" = "firefox.desktop";
      "application/xhtml+xml" = "firefox.desktop";
      "application/pdf" = "org.pwmt.zathura.desktop";
      "text/plain" = "micro.desktop";
      "application/x-shellscript" = "micro.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
      "x-scheme-handler/xmpp" = "org.gajim.Gajim.desktop";
      "x-scheme-handler/discord" = "vesktop.desktop";
      "x-scheme-handler/sgnl" = "signal.desktop";
      "x-scheme-handler/signalcaptcha" = "signal.desktop";
      "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
      "x-scheme-handler/cursor" = "cursor-url-handler.desktop";
    }
    // lib.genAttrs archiveTypes (_: archiveHandler)
    // lib.genAttrs audioTypes (_: mpvHandler)
    // lib.genAttrs videoTypes (_: mpvHandler);
    };
  };
}
