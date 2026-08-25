# System fonts. Family names here must match greetd, GTK, Sway, Firefox, and the CLI wrappers.
# Put fonts in fonts.packages — adding them to environment.systemPackages alone won't register with fontconfig.
{ pkgs, ... }:
{
  fonts = {
    # We leave enableDefaultPackages off (the NixOS default). That gives Noto coverage instead of DejaVu/Liberation.
    packages = with pkgs; [
      # UI sans: unpatched Inter plus nerd-patched "Inter Nerd Font" for icons in the UI.
      inter
      inter-nerdfont
      # Monospace for Ghostty, Firefox, and XFCE. Nerd Fonts 3 uses this exact family string.
      nerd-fonts.jetbrains-mono
      # Icon glyphs for unpatched families. Inter Nerd Font already includes them.
      nerd-fonts.symbols-only
      noto-fonts
      noto-fonts-cjk-sans
      # Twitter Color Emoji uses CBDT bitmaps. Do not add noto-fonts-color-emoji — fontconfig
      # prefers any color emoji and may ignore the order in defaultFonts.emoji.
      twitter-color-emoji
      font-awesome
      # Metric-compatible Arial/Times/Courier stand-ins. Wine and FL Studio look up LiberationSans by name.
      liberation_ttf
    ];

    fontconfig = {
      # Subpixel rendering for the 4K panel at 2× scale (~163 DPI, still below NixOS's ~200 DPI cutoff).
      antialias = true;
      hinting = {
        enable = true;
        # hintslight keeps vertical autohint without squashing glyph shapes (Arch's default).
        style = "slight";
      };
      subpixel = {
        # Landscape LCD stripe order, matching sway's subpixel rgb on DP-3.
        rgba = "rgb";
        # FreeType's default LCD filter. Pair with rgba≠none or you get color fringing.
        lcdfilter = "default";
      };
      # NixOS leaves this off by default. Twitter Color Emoji is CBDT/CBLC bitmaps and Firefox
      # won't draw them unless embedded bitmaps are enabled.
      useEmbeddedBitmaps = true;

      # Default font families — first name wins, later entries are fallbacks.
      defaultFonts = {
        # Inter stands in for serif on purpose to match Firefox; Noto Serif is the real serif fallback.
        serif = [ "Inter Nerd Font" "Noto Serif" ];
        sansSerif = [ "Inter Nerd Font" "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font Mono" ];
        emoji = [ "Twitter Color Emoji" ];
      };
    };
  };
}
