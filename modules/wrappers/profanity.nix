# Profanity with store-backed profrc via -c. The -t flag only searches
# $XDG_CONFIG_HOME/profanity/themes, then compile-time THEMES_PATH.
# Do not set XDG_CONFIG_HOME on the wrapper — /url open would leak it to Firefox.
# Accounts and logs stay in ~/.local/share/profanity (untouched).
{ pkgs, ... }:
let
  profrc = pkgs.writeText "profrc" ''
    [omemo]
    policy=always
    log=redact

    [carbons]
    enabled=true

    [ui]
    enc.warn=on
    splash=false
    history=true
    theme=tokyonight
    intype=on
    wrap=true
    privileges=on
    presence=on
    statuses.console=online
    statuses.chat=none
    statuses.muc=none

    [connection]
    reconnect=30
    autoping=60

    [notifications]
    typing=on
    invite=on
    sub=on
    remind=60

    [logging]
    chlog=on
    grlog=off
  '';

  theme = pkgs.writeText "tokyonight" ''
    [colours]
    bkgnd=black
    titlebar=black
    statusbar=black
    titlebar.text=white
    titlebar.brackets=cyan
    titlebar.encrypted=green
    titlebar.unencrypted=red
    titlebar.untrusted=red
    titlebar.trusted=green
    titlebar.online=green
    titlebar.offline=red
    titlebar.away=yellow
    titlebar.chat=green
    titlebar.dnd=magenta
    titlebar.xa=yellow
    statusbar.text=white
    statusbar.brackets=cyan
    statusbar.active=cyan
    statusbar.current=bold_cyan
    statusbar.new=bold_magenta
    statusbar.time=cyan
    main.text=white
    main.text.history=cyan
    main.text.me=bold_cyan
    main.text.them=bold_magenta
    main.time=cyan
    main.splash=bold_cyan
    input.text=white
    online=green
    away=yellow
    chat=green
    dnd=magenta
    xa=yellow
    offline=red
    typing=cyan
    gone=red
    error=bold_red
    incoming=bold_cyan
    roominfo=cyan
    roommention=bold_magenta
    me=bold_cyan
    them=bold_magenta
    roster.header=bold_blue
    occupants.header=bold_blue
    receipt.sent=cyan
    untrusted=bold_red

    [ui]
    beep=false
    flash=false
    splash=false
    wrap=true
    enc.warn=true
    occupants=true
    occupants.size=15
    roster=true
    roster.size=25
    roster.offline=false
    roster.by=presence
    privileges=true
    presence=true
    intype=true
    omemo.char=🔒
  '';

  # preRun values must be a single argv token — nix-wrappers does not quote --run arguments.
  linkTheme = pkgs.writeShellScript "profanity-link-theme" ''
    mkdir -p "$HOME/.config/profanity/themes"
    ln -sfn ${theme} "$HOME/.config/profanity/themes/tokyonight"
  '';
in
{
  wrappers.profanity = {
    basePackage = pkgs.profanity;
    systemWide = true;
    executables.profanity = {
      preRun = [ "${linkTheme}" ];
      args.prefix = [
        "-c"
        "${profrc}"
        "-t"
        "tokyonight"
      ];
    };
  };
}
