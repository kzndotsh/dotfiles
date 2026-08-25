# gnome-keyring — desktop only (via desktop/). greetd does not substack login PAM.
# NixOS defaults: gnome-keyring.enable false; greetd.enableGnomeKeyring false.
# Sway also starts gnome-keyring-daemon --components=secrets (sway/autostart.nix).
# https://wiki.nixos.org/wiki/GNOME
{
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
}
