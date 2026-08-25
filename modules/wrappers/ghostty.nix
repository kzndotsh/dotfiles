{ pkgs, ... }:
{
  wrappers.ghostty = {
    basePackage = pkgs.ghostty;
    systemWide = true;
    executables.ghostty = {
      args.prefix = [
        "--config-file=${pkgs.writeText "ghostty.conf" ''
          theme = TokyoNight Night
          font-family = JetBrainsMono Nerd Font Mono
          font-size = 14
          window-padding-x = 8
          window-padding-y = 8
          window-padding-balance = true
          window-padding-color = extend
          background-opacity = 0.95
          cursor-style = block_hollow
          cursor-style-blink = false
          mouse-hide-while-typing = true
          copy-on-select = true
          clipboard-trim-trailing-spaces = true
          scrollback-limit = 10000
          confirm-close-surface = false
          window-inherit-working-directory = true
          gtk-single-instance = true
          quit-after-last-window-closed = true
          quit-after-last-window-closed-delay = 5m
          bold-color = bright
          unfocused-split-opacity = 0.85
          gtk-titlebar = false
          gtk-tabs-location = hidden
          async-backend = io_uring
          shell-integration-features = sudo,ssh-env,ssh-terminfo
        ''}"
      ];
    };
  };
}
