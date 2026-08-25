{ lib, config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./user.nix
    ../../modules/wrappers
    ../../modules/nix
    ../../modules/desktop
    ../../modules/desktop/sway
    ../../modules/boot
    ../../modules/hardware
    ../../modules/shell
    ../../modules/programs
    ../../modules/services
    ../hardened-vm/nixvirt.nix
    ../../modules/hardening/ssh.nix
    ../../modules/hardening/baseline.nix
    ../../modules/network
    ../../modules/packages
    ../../modules/dev
    ../../modules/gaming
    ../../modules/music
    ../../modules/wine
  ];

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  documentation.dev.enable = true;
  services.xserver.xkb.layout = "us";

  system.stateVersion = "26.05";

  # Never delete imperative users (useradd). Old generations may lack kaizen;
  # a reboot into those must not wipe kaizen if we later set mutableUsers false.
  users.mutableUsers = true;

  networking = {
    hostName = config.my.hostName;
    networkmanager.ethernet.macAddress = lib.mkForce "permanent";
  };

  # sshd ciphers from hardening/ssh.nix. Forwarding stays OpenSSH default (yes).
  # VPS pins AllowTcpForwarding/PermitTunnel off in hosts/vps/configuration.nix.
  services.openssh.settings.PermitRootLogin = "no";

  gaming = {
    enable = true;
    wine.enable = true;
    emulators.enable = true;
    audio.lowLatency.enable = true;
    lutris.enable = true;
    heroic.enable = true;
    bottles.enable = true;
    minecraft.prismLauncher.enable = true;
    runelite.enable = true;
  };

  music = {
    enable = true;
    daw = {
      bitwig.enable = true;
      lmms.enable = true;
      flstudio.enable = true;
    };
    plugins = {
      synths.enable = true;
      effects.enable = true;
      drums.enable = true;
    };
    tools.enable = true;
  };

  ai.voice = {
    speaches.enable = true;
    kokoro.enable = true;
    fish.enable = true;
    moss.enable = false;
    chatterbox.enable = false;
    openWebui.stt = "speaches";
    openWebui.tts = "fish";
  };
}
