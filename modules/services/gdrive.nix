# On-demand Google Drive at /mnt/gdrive. Token stays in the user's rclone.conf (not the Nix store).
# Automount so switch/boot does not talk to Google until something opens the path.
#
# Left at rclone defaults on purpose (Saltbox sets these for Plex streaming):
# buffer-size, vfs-read-chunk-size, vfs-read-ahead, drive-chunk-size, drive-pacer-*.
# Also no remote-control vfs/refresh and no idle unmount: both throw away the dir cache.
{ config, pkgs, ... }:
let
  user = config.users.users.${config.my.username};
  rcloneConfig = "${config.my.home}/.config/rclone/rclone.conf";
in
{
  # PID 1's PATH is fsPackages. mount.rclone and fusermount3 both have to be on it;
  # rclone's systemd fallback (/bin:/usr/bin) does not exist on NixOS.
  system.fsPackages = [
    pkgs.rclone
    pkgs.fuse3
  ];

  programs.fuse = {
    enable = true;
    # Root is the one mounting, but allow_other is still gated by fuse.conf.
    userAllowOther = true;
  };

  # Cache is root-only. The desktop user reads it through the FUSE mount, not this directory.
  systemd.tmpfiles.rules = [
    "d /var/cache/rclone 0700 root root -"
  ];

  fileSystems."/mnt/gdrive" = {
    # Must match the remote name from `rclone config`.
    device = "gdrive:";
    fsType = "rclone";
    options = [
      # Block device nodes on a network filesystem.
      "nodev"
      # A missing token or a dead Google must not fail boot or switch.
      "nofail"
      # The daemon is root. Without this the desktop user cannot see the mount.
      "allow_other"
      # Hand flags to rclone through the environment so they do not show up in ps.
      "args2env"
      # Wait for the network. Do not mount during early boot.
      "_netdev"
      # Start on first access, not at boot.
      "x-systemd.automount"
      # Absolute path. Mount units have no HOME, so rclone will not find ~/.config.
      "config=${rcloneConfig}"
      # Sparse-file cache. Full mode only stores the byte ranges something actually read.
      "cache-dir=/var/cache/rclone"
      # Reads and writes go through that cache, so seek and save work like a normal disk.
      "vfs-cache-mode=full"
      # Size and mtime only. Hashing every cached open is an extra Drive metadata call.
      "vfs-fast-fingerprint"
      # Evict by the size cap below, not by age. Re-downloads are the expensive part.
      "vfs-cache-max-age=87600h"
      # Headroom under the cap. The cache can overshoot between poll ticks, and open files cannot be evicted.
      "vfs-cache-max-size=50G"
      "vfs-cache-min-free-space=20G"
      # Drive pushes changes via poll. A long listing cache avoids walking the tree again.
      # poll-interval must stay shorter than this.
      "dir-cache-time=1000h"
      # How often to ask Drive what changed. Faster than rclone's 1m default, still cheap.
      "poll-interval=15s"
      # Docs/Sheets/Slides are not files. Exporting them from a file manager burns quota.
      "drive-skip-gdocs"
      # HTTP idle timeout. Default 5m drops a slow large upload.
      "timeout=10m"
      # Mount is root's. Present files as the desktop user.
      "uid=${toString user.uid}"
      "gid=${toString config.users.groups.${user.group}.gid}"
    ];
  };
}
