{ pkgs, ... }:
{
  wrappers.fuzzel = {
    basePackage = pkgs.fuzzel;
    systemWide = true;
    executables.fuzzel = {
      args.prefix = [
        "--config=${pkgs.writeText "fuzzel.ini" ''
          font=Inter Nerd Font:size=14
          dpi-aware=no
          terminal=ghostty -e
          prompt=>  
          icons-enabled=yes
          lines=12
          width=22
          layer=top

          [colors]
          background=1a1b26ff
          text=c0caf5ff
          match=7aa2f7ff
          selection=292e42ff
          selection-text=c0caf5ff
          border=7aa2f7ff

          [border]
          width=1
          radius=0
        ''}"
      ];
    };
  };
}
