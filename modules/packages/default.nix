{ pkgs, ... }:
let
  # nixpkgs 0.6.10 hangs on Python 3.14 (cameraptzmidi ctypes layout). Fixed upstream post-tag.
  cameractrlsFixed = pkgs.cameractrls.overrideAttrs (_old: {
    version = "0.6.10-unstable-2026-07-16";
    src = pkgs.fetchFromGitHub {
      owner = "soyersoyer";
      repo = "cameractrls";
      rev = "6f388257ac21a0e91b143ad11cb2457036fa2c27";
      hash = "sha256-tAfLiGPiumh9RD9k5BfD3Lu1G5NKuCK4PMS2gmGZUcw=";
    };
  });
in
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
    # Webcam UVC controls / preview (EMEET Nova 4K, etc.).
    v4l-utils
    cameractrlsFixed
    (cameractrlsFixed.override { withGtk = 4; })
    guvcview
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
    czkawka-full
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
    glow
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
    nvtopPackages.amd
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
