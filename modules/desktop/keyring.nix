# gnome-keyring for the desktop session. greetd does not stack login PAM, so unlock is configured on greetd directly.
# NixOS defaults both gnome-keyring and greetd.enableGnomeKeyring to false.
# Sway also starts gnome-keyring-daemon --components=secrets in sway/autostart.nix.
{
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
}
