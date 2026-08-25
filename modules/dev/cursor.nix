# Cursor argv.json — desktop only (via modules/dev/). VM does not import this dir.
# password-store=gnome-libsecret uses gnome-keyring (modules/desktop/keyring.nix).
# Do not overwrite an existing argv.json (user may have changed it).
# https://www.cursor.com/docs
{
  system.userActivationScripts.cursor.text = ''
    mkdir -p $HOME/.config/Cursor
    [ -f $HOME/.config/Cursor/argv.json ] || cat > $HOME/.config/Cursor/argv.json << 'EOF'
{"password-store":"gnome-libsecret"}
EOF
  '';
}
