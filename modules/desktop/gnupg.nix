# mise imports release keys through gpg --import, so the homedir must be mode 0700 with a writable keybox.
# Desktop only (via desktop/). GNUPGHOME is set in xdg.nix.
{ pkgs, lib, config, ... }:
let
  homeDir = config.my.home;
in
{
  system.userActivationScripts.gnupg-xdg-bootstrap.text = ''
    install -d -m 0700 -o ${config.my.username} -g users "${homeDir}/.local/share/gnupg"
    /run/wrappers/bin/sudo -u ${config.my.username} ${pkgs.bash}/bin/bash -lc ${lib.escapeShellArg "HOME=${homeDir} ${lib.getExe pkgs.gnupg} --homedir ${homeDir}/.local/share/gnupg --batch --no-tty --list-keys >/dev/null 2>&1 || true"}
  '';
}
