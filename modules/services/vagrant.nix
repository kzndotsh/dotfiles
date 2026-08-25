# Vagrant with libvirt on the desktop. libvirtd/virt-manager are in libvirt.nix;
# NixVirt domain/pool/network XML is in hosts/hardened-vm/nixvirt.nix.
# nixpkgs vagrant on Linux ships vagrant-libvirt as a system plugin — do not vagrant plugin install it.
# HashiCorp's default provider is still VirtualBox, so we set env vars in zsh below.
{ pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    vagrant # Linux build bundles vagrant-libvirt under $out/vagrant-plugins
    libvirt # virsh / virt-install — also on PATH when libvirtd is enabled
  ];

  # Start and autostart the libvirt network named "default".
  # NixOS copies stock default.xml (virbr0, 192.168.122.0/24) if missing but does not start the network.
  # If "default" already exists we only start/autostart it. On this host NixVirt owns that name:
  # same bridge virbr0, subnet 192.168.74.0/24 (subnet_byte = 74). hardened-vm attaches to network "default".
  # Vagrant's DHCP network is separate: vagrant-libvirt creates 192.168.121.0/24 on first vagrant up.
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

  # Keep NetworkManager off libvirt bridges so Vagrant DHCP does not stall on "Waiting for domain to get an IP".
  # The wiki also suggests firewall.trustedInterfaces — our desktop firewall already allows all TCP/UDP ports.
  # virbr74 is a leftover name guess from subnet_byte 74; the live NixVirt bridge is virbr0.
  networking.networkmanager.unmanaged = lib.mkAfter [
    "virbr0"
    "virbr1"
    "virbr2"
    "virbr74"
  ];

  # Interactive zsh only — not bash or GUI-launched vagrant. Without these, HashiCorp picks VirtualBox.
  programs.zsh.interactiveShellInit = lib.mkAfter ''
    # Prefer libvirt over HashiCorp's VirtualBox default.
    export VAGRANT_DEFAULT_PROVIDER=libvirt
    export LIBVIRT_DEFAULT_URI=qemu:///system
  '';

  # NFS synced folders need services.nfs.server.enable; we leave NFS off.
  # Home is mode 700 — run chmod a+x ~ if Vagrant reports permission denied on synced folders.
}
