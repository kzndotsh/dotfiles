# Kiro Crew egress through Mullvad. The gateway runs in a network namespace that has a loopback,
# a /30 veth to the host, and the WireGuard interface as its only default route. There is no
# route to the LAN or the host's loopback services, and nothing leaks if the tunnel drops.
#
# The WireGuard UDP socket is created in the host namespace, then the interface is moved in.
# Host forwarders: 127.0.0.1:<port> -> dashboard (for cloudflared and the browser), and the Tor
# SOCKS port back into the namespace.
{ config, lib, pkgs, ... }:
let
  cfg = config.ai.kirocrew;
  conf = cfg.mullvad.configFile;
  hostIp = "10.200.0.1";
  nsIp = "10.200.0.2";
  socat = lib.getExe pkgs.socat;
  active = cfg.enable && cfg.mullvad.enable;

  forwarder = {
    description,
    script,
    inNamespace ? false,
  }: {
    inherit description;
    after = [ "mullvad-crew.service" ];
    bindsTo = [ "mullvad-crew.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = pkgs.writeShellScript "kirocrew-forward" script;
      Restart = "on-failure";
      RestartSec = 3;
      DynamicUser = true;
    } // lib.optionalAttrs inNamespace {
      NetworkNamespacePath = "/run/netns/crew";
    };
  };
in
{
  config = lib.mkIf active {
    systemd.services = {
      mullvad-crew = {
        description = "Network namespace for Kiro Crew with a Mullvad WireGuard route";
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        path = with pkgs; [ iproute2 wireguard-tools procps gnused gawk coreutils bash ];
        unitConfig.ConditionPathExists = conf;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          set -eu
          ip netns del crew 2>/dev/null || true
          ip link del wg-crew 2>/dev/null || true
          ip link del veth-crew 2>/dev/null || true

          ip netns add crew
          ip -n crew link set lo up
          ip netns exec crew sysctl -qw net.ipv6.conf.all.disable_ipv6=1

          ip link add veth-crew type veth peer name veth-crew-ns netns crew
          ip addr add ${hostIp}/30 dev veth-crew
          ip link set veth-crew up
          ip -n crew addr add ${nsIp}/30 dev veth-crew-ns
          ip -n crew link set veth-crew-ns up

          # Created here so the encrypted UDP leaves through the host's default route.
          ip link add wg-crew type wireguard
          wg setconf wg-crew <(wg-quick strip ${lib.escapeShellArg conf})
          ip link set wg-crew netns crew
          for a in $(sed -n 's/^Address *= *//p' ${lib.escapeShellArg conf} | tr ',' ' '); do
            case "$a" in *:*) ;; *) ip -n crew addr add "$a" dev wg-crew ;; esac
          done
          ip -n crew link set wg-crew mtu 1380 up
          ip -n crew route add default dev wg-crew

          dns=$(sed -n 's/^DNS *= *//p' ${lib.escapeShellArg conf} | tr ',' ' ' | awk '{print $1}')
          mkdir -p /etc/netns/crew
          echo "nameserver ''${dns:-10.64.0.1}" > /etc/netns/crew/resolv.conf
        '';
        preStop = ''
          ip netns del crew 2>/dev/null || true
        '';
      };

      # The dashboard binds loopback inside the namespace; expose it on the veth, then on the
      # host's loopback so cloudflared (and a local browser) keep using 127.0.0.1:<port>.
      kirocrew-forward-ns = forwarder {
        description = "Kiro Crew: namespace dashboard and Tor forwarders";
        inNamespace = true;
        script = ''
          ${socat} TCP-LISTEN:${toString cfg.port},bind=${nsIp},fork,reuseaddr TCP:127.0.0.1:${toString cfg.port} &
          ${socat} TCP-LISTEN:9050,bind=127.0.0.1,fork,reuseaddr TCP:${hostIp}:9050 &
          wait -n
        '';
      };

      kirocrew-forward-dashboard = forwarder {
        description = "Kiro Crew: host 127.0.0.1:${toString cfg.port} to the namespace dashboard";
        script = ''
          exec ${socat} TCP-LISTEN:${toString cfg.port},bind=127.0.0.1,fork,reuseaddr TCP:${nsIp}:${toString cfg.port}
        '';
      };

      kirocrew-forward-tor = forwarder {
        description = "Kiro Crew: Tor SOCKS into the namespace";
        script = ''
          exec ${socat} TCP-LISTEN:9050,bind=${hostIp},fork,reuseaddr TCP:127.0.0.1:9050
        '';
      };
    };

    networking = {
      # The desktop firewall allows every TCP port, so per-interface allow lists do nothing.
      # Put the namespace's policy ahead of the nixos-fw chain: replies and the Tor forwarder only.
      firewall.extraCommands = ''
        iptables -D INPUT -i veth-crew -j DROP 2>/dev/null || true
        iptables -D INPUT -i veth-crew -p tcp --dport 9050 -j ACCEPT 2>/dev/null || true
        iptables -D INPUT -i veth-crew -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || true
        iptables -I INPUT 1 -i veth-crew -j DROP
        iptables -I INPUT 1 -i veth-crew -p tcp --dport 9050 -j ACCEPT
        iptables -I INPUT 1 -i veth-crew -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
      '';

      firewall.extraStopCommands = ''
        iptables -D INPUT -i veth-crew -j DROP 2>/dev/null || true
        iptables -D INPUT -i veth-crew -p tcp --dport 9050 -j ACCEPT 2>/dev/null || true
        iptables -D INPUT -i veth-crew -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || true
      '';

      # NetworkManager would otherwise try to configure the new interfaces.
      networkmanager.unmanaged = [
        "interface-name:veth-crew"
        "interface-name:wg-crew"
      ];
    };
  };
}
