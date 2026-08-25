# Let wheel unlock and mount disks through udisks2 without a password — desktop only.
#
# Stock udisks2 (active session): removable encrypted-unlock and filesystem-mount get yes;
# *-system actions normally ask auth_admin_keep (internal / HintSystem disks).
# This rule upgrades *-system to YES for wheel, pairing with passwordless sudo in desktop/security.nix.
# Not covered: *-other-seat, *-crypttab, filesystem-fstab. Root LUKS is initrd, not these actions.
# udisks2.enable is in daemons.nix; the polkit agent is polkit_gnome in sway autostart.
{
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
        subject.isInGroup("wheel") &&
        (
          action.id == "org.freedesktop.udisks2.encrypted-unlock" ||
          action.id == "org.freedesktop.udisks2.encrypted-unlock-system" ||
          action.id == "org.freedesktop.udisks2.filesystem-mount" ||
          action.id == "org.freedesktop.udisks2.filesystem-mount-system"
        )
      ) {
        return polkit.Result.YES;
      }
    });
  '';
}
