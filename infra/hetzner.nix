# Hetzner Cloud VPS. Resource names are state keys — do not rename.
{ identity, lib, ... }:
let
  any = [
    "0.0.0.0/0"
    "::/0"
  ];
  inbound = protocol: port: description: {
    direction = "in";
    inherit protocol port description;
    source_ips = any;
  };
  tcp = inbound "tcp";
  udp = inbound "udp";
in
{
  resource = {
    hcloud_ssh_key.main = {
      name = identity.username;
      public_key = "${identity.sshKey} ${identity.username}";
    };

    hcloud_firewall.vps = {
      name = "vps-firewall";
      # 2222 is initrd LUKS unlock at boot only (slim kzn stack has no git SSH).
      rule = [
        (tcp "22" "SSH")
        (tcp "2222" "SSH initrd LUKS unlock")
        (tcp "80" "HTTP (ACME)")
        (tcp "443" "HTTPS")
        (tcp "5222" "XMPP c2s")
        (tcp "5223" "XMPP c2s TLS")
        (tcp "5269" "XMPP s2s")
        (tcp "5270" "XMPP s2s TLS")
        (tcp "5280-5281" "XMPP HTTP")
        (tcp "3478" "TURN TCP")
        (udp "3478" "TURN UDP")
        (tcp "5349" "TURN TLS")
        (udp "5349" "TURN TLS UDP")
        (udp "49152-65535" "TURN relay")
        (tcp "6697" "ZNC IRC")
      ];
    };

    hcloud_server.vps = {
      name = "vps";
      server_type = "cx33"; # Gen3: 3 vCPU, 8GB RAM, 80GB NVMe
      location = "nbg1"; # Nuremberg
      image = "debian-12"; # replaced by nixos-anywhere
      ssh_keys = [ (lib.tf.ref "hcloud_ssh_key.main.id") ];
      firewall_ids = [ (lib.tf.ref "hcloud_firewall.vps.id") ];
      backups = true;
      public_net = {
        ipv4_enabled = true;
        ipv6_enabled = true;
      };
    };
  };

  output = {
    vps_ipv4.value = lib.tf.ref "hcloud_server.vps.ipv4_address";
    vps_ipv6.value = lib.tf.ref "hcloud_server.vps.ipv6_address";
  };
}
