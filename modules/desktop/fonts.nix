# System fonts + fontconfig. Desktop barrel + hardened-vm cherry-pick (not VPS).
# Put fonts in fonts.packages — environment.systemPackages does not register them
# with fontconfig. https://wiki.nixos.org/wiki/Fonts
# https://fontconfig.pages.freedesktop.org/fontconfig/fontconfig-user.html
# https://wiki.archlinux.org/title/Font_configuration
# Family names must match greetd / GTK / Sway / Firefox / wrappers / XFCE.
{ pkgs, ... }:
{
  fonts = {
    # enableDefaultPackages stays off (NixOS default). Coverage is Noto, not DejaVu/gyre.
    packages = with pkgs; [
      # UI: unpatched "Inter" (rsms.me) + nerd-patched "Inter Nerd Font".
      # https://rsms.me/inter/  https://gitlab.com/mid_os/inter-nerdfont
      inter
      inter-nerdfont
      # Ghostty / Firefox / XFCE mono. Nerd Fonts 3 family is this exact string.
      # https://www.nerdfonts.com/
      nerd-fonts.jetbrains-mono
      # Icons for unpatched families. Inter Nerd Font already has the glyphs.
      nerd-fonts.symbols-only
      noto-fonts
      noto-fonts-cjk-sans
      # CBDT color emoji. Do not add noto-fonts-color-emoji — fontconfig prefers
      # any color emoji and may ignore defaultFonts.emoji order.
      twitter-color-emoji
      font-awesome
      # Metric-compatible Arial / Times / Courier. Wine + flstudio.nix LiberationSans lookup.
      liberation_ttf
    ];

    fontconfig = {
      # ─── Rasterizer ───
      # NixOS defaults: antialias=true, hinting.enable=true, hinting.style=slight,
      # lcdfilter=default, rgba=none. We pin rgba=rgb (NixOS default is none).
      # Wine Xft in wine/default.nix must stay in sync (hintslight / rgb / lcddefault).
      # NixOS: antialias / hinting / lcdfilter have no visible effect above ~200 DPI.
      # DP-3 is 4K @ scale 2; a 27" 4K panel is ~163 DPI, so these still apply.
      antialias = true;
      hinting = {
        enable = true;
        # hintslight: vertical autohint, keep glyph shape. Arch default.
        style = "slight";
      };
      subpixel = {
        # Landscape LCD stripe order. Matches sway `subpixel rgb` on DP-3.
        rgba = "rgb";
        # FreeType FT_LCD_FILTER_DEFAULT. Pair with rgba≠none or you get color fringing.
        lcdfilter = "default";
      };
      # NixOS default false. Color emoji (Twitter Color Emoji) is CBDT/CBLC bitmaps;
      # Firefox will not draw them without this.
      # https://wiki.nixos.org/wiki/Fonts#Noto_Color_Emoji_doesn't_render_on_Firefox
      useEmbeddedBitmaps = true;

      # ─── Generic families ───
      # First name wins; later entries are fallbacks (CJK / missing glyphs).
      defaultFonts = {
        # Inter is sans. Same choice as firefox.nix serif lock — UI consistency, not a serif face.
        serif = [ "Inter Nerd Font" "Noto Serif" ];
        sansSerif = [ "Inter Nerd Font" "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font Mono" ];
        emoji = [ "Twitter Color Emoji" ];
      };
    };
  };
}
