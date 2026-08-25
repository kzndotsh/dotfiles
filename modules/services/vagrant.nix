# Vagrant + libvirt default-network start + NM unmanaged bridges — desktop only (via services/).
# Daemon/virt-manager: libvirt.nix. NixVirt domain/pool/network: hosts/hardened-vm/nixvirt.nix.
# libvirtd group is on the host (user.nix), not here.
#
# nixpkgs `vagrant` on Linux: withLibvirt = true — ships vagrant-libvirt as a system
# plugin (do not `vagrant plugin install`). HashiCorp default provider is VirtualBox.
# https://wiki.nixos.org/wiki/Vagrant
# https://developer.hashicorp.com/vagrant/docs/providers/default
# https://vagrant-libvirt.github.io/vagrant-libvirt/
{ pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    vagrant # Linux: vagrant-libvirt via $out/vagrant-plugins (see pkgs.vagrant postInstall)
    libvirt # virsh / virt-install — also on PATH via libvirtd.enable
  ];

  # Start + autostart the libvirt network named "default".
  # NixOS libvirtd-config copies stock XML to /var/lib/libvirt/qemu/networks/default.xml
  # (virbr0, 192.168.122.0/24) if missing — it does not start the network.
  # https://libvirt.org/formatnetwork.html
  #
  # If `default` is already defined, we only start/autostart it (do not redefine).
  # On this host NixVirt owns `default`: same name, virbr0, 192.168.74.0/24
  # (templates.bridge subnet_byte = 74; default bridge_name is virbr0, not virbr74).
  # hardened-vm attaches to source network = "default".
  #
  # Vagrant DHCP is NOT this network. vagrant-libvirt default management net is
  # name `vagrant-libvirt`, 192.168.121.0/24 (created on first `vagrant up`).
  systemd.services.libvirt-default-network = {
    description = "Libvirt default NAT network (Vagrant / generic guests)";
    after = [ "libvirtd.service" "libvirtd-config.service" ];
    wants = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -euo pipefail
      VIRSH="${pkgs.libvirt}/bin/virsh -c qemu:///system"
      NET=/var/lib/libvirt/qemu/networks/default.xml
      if [ ! -f "$NET" ]; then
        echo "libvirt default network XML missing — is libvirtd enabled?" >&2
        exit 1
      fi
      if ! $VIRSH net-info default &>/dev/null; then
        $VIRSH net-define "$NET"
      fi
      $VIRSH net-start default 2>/dev/null || true
      $VIRSH net-autostart default
    '';
  };

  # NixOS default []. Wiki lists virbr0/1/2 so NM does not steal libvirt bridges
  # (DHCP stall: "Waiting for domain to get an IP address").
  # Wiki also wants firewall.trustedInterfaces on those ifaces — desktop firewall
  # already allows TCP/UDP 1-65535 (modules/network), so we skip that.
  # virbr74: leftover name guess from subnet_byte 74. Live NixVirt bridge is virbr0.
  networking.networkmanager.unmanaged = lib.mkAfter [
    "virbr0"
    "virbr1"
    "virbr2"
    "virbr74" # name guess from subnet_byte 74; live NixVirt bridge is virbr0
  ];

  # NixOS default "". Interactive zsh only — not bash, not GUI-launched vagrant.
  # HashiCorp: VAGRANT_DEFAULT_PROVIDER (else VirtualBox).
  # vagrant-libvirt: LIBVIRT_DEFAULT_URI if Vagrantfile does not set uri
  # (qemu:///system = system session; needs libvirtd group).
  programs.zsh.interactiveShellInit = lib.mkAfter ''
    # Vagrant + libvirt on this host (KVM/QEMU system session)
    export VAGRANT_DEFAULT_PROVIDER=libvirt
    export LIBVIRT_DEFAULT_URI=qemu:///system
  '';

  # Wiki NFS synced folders need services.nfs.server.enable = true (NixOS default false).
  # We leave NFS off. NixOS home is mode 700 — `chmod a+x ~` if Vagrant permission-denied.
}
