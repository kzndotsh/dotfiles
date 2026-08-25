# swaylock-effects (the binary is still named swaylock).
{
  environment.etc."xdg/swaylock/config".text = ''
    # Tokyo Night — matches sway client.* colors in config.nix
    color=1a1b26
    inside-color=1a1b26
    inside-ver-color=24283b
    inside-wrong-color=24283b
    ring-color=7aa2f7
    ring-ver-color=73daca
    ring-wrong-color=db4b4b
    key-hl-color=73daca
    bs-hl-color=db4b4b
    text-color=c0caf5
    text-ver-color=c0caf5
    text-wrong-color=f7768e
    indicator-radius=100
    indicator-thickness=10
    font=Inter Nerd Font
    show-failed-attempts

    # swaylock-effects extras
    screenshots
    effect-blur=7x5
    effect-vignette=0.5:0.5
    clock
    timestr=%H:%M
    datestr=%a, %b %d
    grace=3
    fade-in=0.2
  '';

  # swaylock reads ~/.config/swaylock/config first. Pin to /etc so local files can't override.
  system.userActivationScripts.swaylock-link.text = ''
    mkdir -p $HOME/.config/swaylock
    ln -sfn /etc/xdg/swaylock/config $HOME/.config/swaylock/config
  '';
}
