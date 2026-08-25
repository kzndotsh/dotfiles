# Passwordless udisks2 unlock/mount for wheel — desktop only (via services/).
# security.polkit.enable default is false; extraConfig default is "".
# Rules land in /etc/polkit-1/rules.d/10-nixos.rules (Duktape JS).
# https://wiki.nixos.org/wiki/Polkit
# https://www.freedesktop.org/software/polkit/docs/latest/polkit.8.html#polkit-rules
# Action IDs: https://storaged.org/doc/udisks2-api/latest/udisks-polkit-actions.html
#
# Official udisks2 defaults (active session):
#   encrypted-unlock / filesystem-mount        → yes (removable)
#   *-system                                   → auth_admin_keep (internal / HintSystem)
# This rule upgrades *-system to YES for wheel (no password). Pairs with
# security.sudo.wheelNeedsPassword = false in modules/desktop/security.nix.
# Not covered: *-other-seat, *-crypttab, filesystem-fstab.
#
# udisks2.enable is in daemons.nix. Agent is polkit_gnome in sway/config.nix.
# Root LUKS unlock is initrd, not these actions.
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
