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
    ../windows-vm/nixvirt.nix
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

  # Keep users mutable: older generations may not define kaizen, and we do not
  # want a reboot into one of those to delete the live account if we ever lock users down.
  users.mutableUsers = true;

  networking = {
    hostName = config.my.hostName;
    networkmanager.ethernet.macAddress = lib.mkForce "permanent";
  };

  # nix-topology: NM has no extractor — enp5s0/virbr0 are manual (live: inxi -Fxxxz / ip route).
  topology.self = {
    name = "ikigai";
    hardware.info = "Ryzen 7 5800X · RX 6700 XT · ASRock B550AM · libvirt hypervisor";
    interfaces.enp5s0 = {
      network = "home";
      type = "ethernet";
      icon = "interfaces.ethernet";
      addresses = [ "DHCP" ];
      gateways = [ "192.168.1.254" ];
    };
    interfaces.wlp4s0 = {
      type = "wifi";
      icon = "interfaces.wifi";
      addresses = [ "down" ];
    };
    interfaces.virbr0 = {
      network = "virt";
      virtual = true;
      type = "bridge";
      icon = "interfaces.tap";
      addresses = [ "192.168.74.1/24" ];
      physicalConnections = [
        (config.lib.topology.mkConnection "hardened-vm" "enp1s0")
        (config.lib.topology.mkConnection "windows-vm" "eth0")
      ];
    };
    interfaces.docker0 = {
      network = "docker";
      virtual = true;
      type = "bridge";
      icon = "devices.cloud-server";
      addresses = [ "172.17.0.1/16" ];
    };
    interfaces.cf-tunnel = {
      virtual = true;
      type = "tunnel";
      icon = "services.wireguard";
      physicalConnections = [
        (config.lib.topology.mkConnection "cloudflare" "edge")
      ];
    };
    services = {
      kiro-gateway = {
        name = "kiro-gateway";
        icon = "services.coder";
        info = "127.0.0.1:9000";
        details.tunnel = { text = "kiro.kzn.sh"; order = 50; };
      };
      copyparty = {
        name = "copyparty";
        icon = "services.samba";
        info = "127.0.0.1:3923";
        details.tunnel = { text = "files (cloudflared)"; order = 50; };
      };
      comfyui = {
        name = "ComfyUI";
        icon = "services.ollama";
        info = "0.0.0.0:8188";
      };
      qbittorrent = {
        name = "qBittorrent";
        icon = "services.transmission";
        info = "127.0.0.1:8080 · torrent :63000";
      };
    };
  };

  # Cipher and MAC settings live in hardening/ssh.nix. TCP forwarding stays at the
  # OpenSSH default here; the VPS turns forwarding and tunnels off in system.nix.
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

  # w-okada RVC — w-okada-setup once, then `w-okada` + virtual mic.
  ai.wOkada = {
    enable = true;
    virtualMic.enable = true;
    server.enable = false;
    defaults = {
      pitchSemitones = 12;
      readChunkSize = 128;
      extraConvertSize = 32768;
      f0Detector = "rmvpe";
      silenceFront = false;
      silentThreshold = 0.0001;
      force = true;
    };
  };
}
