# Kiro Crew — persistent agent workspace. Dashboard on 127.0.0.1:5476.
# Drives nixpkgs kiro-cli. State stays in ~/.kiro/crew (not the Nix store).
# Do not run `kirocrew service install` — that writes /etc/systemd outside Nix.
{ config, lib, pkgs, ... }:
let
  cfg = config.ai.kirocrew;
  inherit (config.my) home;
  # Agents see an empty home, so the desktop gitconfig (1Password signing) is not there.
  confinedGitConfig = pkgs.writeText "kirocrew-gitconfig" ''
    [user]
      name = ${config.my.gitName}
      email = ${config.my.gitEmail}
    [commit]
      gpgsign = false
    [tag]
      gpgsign = false
    [safe]
      directory = *
    [init]
      defaultBranch = main
  '';
  # Crew's launcher hides ~/.ssh and defaults GIT_SSH_COMMAND to keys there, so the one key
  # the agents may use is bound read-only under the Crew state dir and named explicitly.
  sshDir = "${crewDir}/ssh";
  sshKeyName = baseNameOf cfg.confine.gitSshKey;
  confinedGitSsh = lib.concatStringsSep " " [
    "ssh -F /dev/null -i ${sshDir}/${sshKeyName}"
    "-o IdentitiesOnly=yes -o IdentityAgent=none"
    "-o UserKnownHostsFile=${sshDir}/known_hosts -o StrictHostKeyChecking=accept-new"
  ];
  confinedPath = lib.concatStringsSep ":" (
    map (d: "${home}/${d}") [
      ".local/share/mise/shims"
      ".local/bin"
      ".local/share/npm/bin"
      ".local/share/pnpm/bin"
      ".local/share/bun/bin"
      ".local/share/python/bin"
    ]
    ++ [ "/run/wrappers/bin" "/run/current-system/sw/bin" ]
  );
  gateway = {
    description = "Kiro Crew gateway";
    serviceConfig = {
      ExecStart = "${lib.getExe cfg.package} gateway --port ${toString cfg.port}";
      Restart = "on-failure";
      RestartSec = 5;
      WorkingDirectory = home;
    } // lib.optionalAttrs cfg.confine.enable {
      # Agents inherit this mount namespace, so ~/.secrets, ~/.ssh and other projects stay invisible.
      ProtectHome = "tmpfs";
      BindPaths =
        map (d: "-${home}/${d}") cfg.confine.stateDirs
        ++ map (d: "-${d}") cfg.confine.projectDirs
        # Shell hooks (mise, starship, direnv) write here. Crew's own dirs stand in for the desktop's.
        ++ [
          "${crewDir}/xdg-cache:${home}/.cache"
          "${crewDir}/xdg-state:${home}/.local/state"
          # npm ignores XDG and caches in ~/.npm; npx (MCP servers) fails without a writable one.
          "${crewDir}/npm-cache:${home}/.npm"
        ];
      BindReadOnlyPaths = map (d: "-${home}/${d}") cfg.confine.readOnlyDirs
        ++ lib.optional (cfg.confine.gitSshKey != null)
          "${home}/${cfg.confine.gitSshKey}:${sshDir}/${sshKeyName}";
      # Hide /mnt (gdrive automount, crypt) — not under /home. A tmpfs avoids triggering the automounts.
      TemporaryFileSystem = [ "/mnt:ro" ];
      # The desktop user is in docker and libvirtd: either socket is root-equivalent.
      InaccessiblePaths = [
        "-/run/docker.sock"
        "-/var/run/docker.sock"
        "-/run/libvirt"
        "-/run/dbus"
        # The desktop user is a nix trusted-user (wheel), so the daemon socket is a privilege path.
        "-/nix/var/nix/daemon-socket"
      ];
      PrivateTmp = true;
    };
    environment = lib.optionalAttrs cfg.confine.enable {
      GIT_CONFIG_GLOBAL = "${confinedGitConfig}";
    } // lib.optionalAttrs (cfg.confine.enable && cfg.confine.gitSshKey != null) {
      GIT_SSH_COMMAND = confinedGitSsh;
    } // lib.optionalAttrs cfg.confine.enable {
      # Keep tool caches out of the desktop's ~/.cache.
      XDG_CACHE_HOME = "${crewDir}/xdg-cache";
      PATH = lib.mkForce confinedPath;
    };
    # NixOS units only get coreutils/findutils/grep/sed/systemd.
    # The gateway execs host tools by name (`git init`, `gh`, …). Give it
    # the system profile. /run/wrappers wins for setuid helpers. The
    # package wrapper still prefixes kiro-cli-unwrapped so the FHS bwrap
    # `kiro-cli` in the profile does not come first.
    path = [
      "/run/wrappers"
      "/run/current-system/sw"
    ];
  };
  crewDir = "${home}/.kiro/crew";
  pkg = pkgs.callPackage ../../packages/kirocrew { };
  # The gateway only mints owner tokens for callers whose namespaces match its own, and the
  # confined gateway no longer shares your shell's mount and network namespaces. Join them as you.
  tokenHelper = pkgs.writeShellScriptBin "kirocrew-token" ''
    set -eu
    pid=$(systemctl show -p MainPID --value kirocrew)
    [ "$pid" != 0 ] || { echo "kirocrew is not running" >&2; exit 1; }
    cd /
    exec /run/wrappers/bin/sudo ${lib.getExe' pkgs.util-linux "nsenter"} -t "$pid" -m -n \
      -S "$(id -u)" -G "$(id -g)" \
      ${pkgs.coreutils}/bin/env HOME="$HOME" ${lib.getExe cfg.package} token "$@"
  '';
  # Private project dirs live in projectDirsFile, outside the public repo. systemd runs generators
  # at boot and on every daemon-reload; this one turns the list into a BindPaths= drop-in.
  projectsGenerator = pkgs.writeShellScript "kirocrew-projects-generator" ''
    list=${lib.escapeShellArg cfg.confine.projectDirsFile}
    [ -r "$list" ] || exit 0
    binds=
    while IFS= read -r line || [ -n "$line" ]; do
      line=''${line%%#*}
      line=''${line#"''${line%%[![:space:]]*}"}
      line=''${line%"''${line##*[![:space:]]}"}
      [ -n "$line" ] || continue
      case "$line" in
        *[[:space:]]* | *..* | *\"* ) echo "kirocrew-projects: skipping '$line' (whitespace, .. or quotes)" >&2; continue ;;
        ${home}/?*) binds="$binds -$line" ;;
        *) echo "kirocrew-projects: skipping '$line' (must be under ${home})" >&2 ;;
      esac
    done < "$list"
    [ -n "$binds" ] || exit 0
    ${pkgs.coreutils}/bin/mkdir -p "$1/kirocrew.service.d"
    printf '[Service]\nBindPaths=%s\n' "$binds" > "$1/kirocrew.service.d/50-projects.conf"
  '';
in
{
  imports = [ ./kirocrew-mullvad.nix ];

  options.ai.kirocrew = {
    enable = lib.mkEnableOption "Kiro Crew gateway (user service, loopback :5476)";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkg;
      description = "Kiro Crew package (pinned wheel in packages/kirocrew)";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 5476;
      description = "Loopback port for the dashboard and gateway API";
    };

    tunnel.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Named Cloudflare tunnel `crew` → crew.kzn.sh (behind Cloudflare Access; creds from `nix run .#vps-tunnels-sync`)";
    };

    confine = {
      enable = lib.mkEnableOption "hide the rest of $HOME from the gateway and its agents (ProtectHome=tmpfs)";

      projectDirs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Project directories bound read-write into the otherwise empty home (public; private ones go in projectDirsFile)";
      };

      projectDirsFile = lib.mkOption {
        type = lib.types.str;
        default = "${config.my.secretsDir}/kirocrew-projects";
        description = "Untracked list of extra project dirs (absolute, under $HOME, one per line, # comments), bound read-write via a systemd generator. Apply edits with daemon-reload + restart";
      };

      stateDirs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ".kiro" ".local/share/kiro-cli" ];
        description = "Home-relative state the gateway and kiro-cli need, read-write. Missing paths are skipped";
      };

      gitSshKey = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Home-relative private key agents use for git over SSH (read-only bind; the only ~/.ssh file they see)";
      };

      readOnlyDirs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          ".local/share/mise"
          ".local/share/uv"
          ".local/share/npm"
          ".local/share/pnpm"
          ".local/share/bun"
          ".local/share/python"
          ".local/share/cargo"
          ".local/share/rustup"
          ".local/share/go"
          ".local/bin"
          ".config/mise"
          ".config/npm"
          ".config/pip"
          ".config/uv"
          # Search MCP servers read these; only these two files of ~/.secrets are visible to Crew.
          ".secrets/brave-api-key"
          ".secrets/tavily-api-key"
        ];
        description = "Home-relative toolchains and key files the agents use, read-only so they cannot plant binaries the desktop later runs";
      };
    };

    mullvad = {
      enable = lib.mkEnableOption "run the gateway in a network namespace whose only route out is Mullvad WireGuard (kirocrew-mullvad.nix)";

      configFile = lib.mkOption {
        type = lib.types.str;
        default = "${config.my.secretsDir}/mullvad-crew.conf";
        description = "Mullvad WireGuard config (from the Mullvad site, Linux, no kill switch). Kept outside Nix";
      };
    };

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Start the user unit at login (wantedBy default.target)";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ] ++ lib.optional cfg.mullvad.enable tokenHelper;

    systemd = {
      # Same unit name either way; the generator feeds whichever manager runs it.
      generators.kirocrew-projects = lib.mkIf (cfg.confine.enable && cfg.mullvad.enable) projectsGenerator;
      user = {
        generators.kirocrew-projects = lib.mkIf (cfg.confine.enable && !cfg.mullvad.enable) projectsGenerator;

        # The dashboard 403s any Host but loopback, so pin it instead of forwarding crew.kzn.sh.
        services.cloudflared-crew = lib.mkIf cfg.tunnel.enable {
          description = "Cloudflare Tunnel - Kiro Crew";
          after = [ "network-online.target" ] ++ lib.optional (!cfg.mullvad.enable) "kirocrew.service";
          wantedBy = [ "default.target" ];
          unitConfig.ConditionPathExists = "${config.my.secretsDir}/cloudflared/crew.json";
          serviceConfig = {
            ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate --credentials-file ${config.my.secretsDir}/cloudflared/crew.json run --url http://127.0.0.1:${toString cfg.port} --http-host-header 127.0.0.1:${toString cfg.port} crew";
            Restart = "on-failure";
            RestartSec = 5;
          };
        };

        services.kirocrew = lib.mkIf (!cfg.mullvad.enable) (gateway // {
          after = [ "network-online.target" ];
          wantedBy = lib.optionals cfg.autoStart [ "default.target" ];
        });
      };

      tmpfiles.rules =
        lib.optional cfg.tunnel.enable
          "d ${config.my.secretsDir}/cloudflared 0700 ${config.my.username} users -"
        ++ lib.optionals cfg.confine.enable [
          "d ${crewDir}/xdg-cache 0700 ${config.my.username} users -"
          "d ${crewDir}/xdg-state 0700 ${config.my.username} users -"
          "d ${crewDir}/npm-cache 0700 ${config.my.username} users -"
        ] ++ lib.optionals (cfg.confine.enable && cfg.confine.gitSshKey != null) [
          "d ${sshDir} 0700 ${config.my.username} users -"
          "f ${sshDir}/${sshKeyName} 0600 ${config.my.username} users -"
          "f ${sshDir}/known_hosts 0600 ${config.my.username} users -"
        ];

      # Mullvad mode: a system unit (only root can join a network namespace) that still runs as the
      # desktop user. Namespace, tunnel and forwarders live in kirocrew-mullvad.nix.
      services.kirocrew = lib.mkIf cfg.mullvad.enable (gateway // {
        after = [ "network-online.target" "mullvad-crew.service" ];
        wants = [ "network-online.target" ];
        bindsTo = [ "mullvad-crew.service" ];
        wantedBy = lib.optionals cfg.autoStart [ "multi-user.target" ];
        serviceConfig = gateway.serviceConfig // {
          User = config.my.username;
          Group = "users";
          NetworkNamespacePath = "/run/netns/crew";
          BindReadOnlyPaths = gateway.serviceConfig.BindReadOnlyPaths
            ++ [ "/etc/netns/crew/resolv.conf:/etc/resolv.conf" ];
        };
        environment = gateway.environment // { HOME = home; };
      });
    };
  };
}
