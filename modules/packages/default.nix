{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    sops
    weechat
    mcp-nixos
    kiro
    kiro-cli
    pwvucontrol
    ffmpegthumbnailer
    shared-mime-info
    gdk-pixbuf
    webp-pixbuf-loader
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
    teams-for-linux
    signal-desktop
    (gajim.overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [
        python3Packages.setuptools
      ];
      propagatedBuildInputs = old.propagatedBuildInputs ++ [
        python3Packages.gpgme
      ];
    }))
    halloy
    newsflash
    nicotine-plus
    seahorse
    tsukimi
    opencode
    just
    element-desktop
    telegram-desktop
    zoom-us
    cheese
    libreoffice-stable
    obsidian
    pandoc
    typst
    inter
    hunspell
    hunspellDicts.en_US
    tree
    libva-utils
    ffmpeg
    yt-dlp
    man-pages
    man-pages-posix
    libheif
    nix-tree
    nixd
    statix
    deadnix
    nvd
    nix-output-monitor
    inxi
    fastfetch
    ripgrep
    fd
    fzf
    jq
    bat
    comma
    (python3.withPackages (ps: [ ps.python-gnupg ]))
    gnupg
    openssl
    libnotify
    magic-wormhole
    copyparty
    cloudflared
    # session-desktop is commented out — upstream pnpm lockfile was broken (2026-07-08).
    simplex-chat-desktop
    vesktop
    mumble
    gcc
    code-cursor
    duf
    ncdu
    tokei
    tealdeer
    dog
    gping
    hyperfine
    alsa-utils
    wget
    curl
    rsync
    file
    pciutils
    usbutils
    killall
    xclip
    docker-compose
    (chromium.override {
      # Web Bluetooth on Linux (FFE0 UART modules, etc.).
      commandLineArgs = [
        "--enable-features=WebBluetooth,WebBluetoothNewPermissionsBackend"
      ];
    })
    tor-browser
    ethtool
    xdg-ninja
    antigravity-ide
    antigravity-cli
    # Archive and compression tools for file-roller and CLI use.
    gnutar
    gzip
    bzip2
    xz
    zstd
    zip
    unzip
    p7zip
    unar
    unrar
    file-roller
    nautilus
  ];

  environment.pathsToLink = [ "share/thumbnailers" ];
}
