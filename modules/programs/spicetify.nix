{ pkgs, inputs, ... }:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  # This module installs Spotify — do not also add pkgs.spotify to systemPackages.
  programs.spicetify = {
    enable = true;
    # alwaysEnableDevTools is a no-op on this spicetify-nix pin (verified:
    # no --remote-debugging-port/devtools marker anywhere in the built
    # xpui/launcher; in-app Ctrl+Shift+I and the settings config menu don't
    # work either). Don't chase this further: `spotify --remote-debugging-port`
    # attaches fine but Spotify's anti-tamper check kills the process the
    # moment you run anything via CDP Runtime.evaluate (DevTools console
    # counts). A real loaded extension calling the same spclient endpoints
    # is completely stable — verified 2026-08-30, see spicetify-cratesorter
    # project's TODO.md Phase 0. Test via a throwaway enabledExtensions
    # entry instead of fighting DevTools.
    alwaysEnableDevTools = true;
    theme = spicePkgs.themes.tokyoNight;
    colorScheme = "Night";
    enabledExtensions = [
      spicePkgs.extensions.allOfArtist
      spicePkgs.extensions.betterGenres
      spicePkgs.extensions.hidePodcasts
      spicePkgs.extensions.lastfm
      spicePkgs.extensions.madeForYouShortcut
      spicePkgs.extensions.shuffle
      {
        src = "${inputs.findDupeTracks}/dist";
        name = "findDupeTracks.mjs";
      }
      {
        src = inputs.cratedigger;
        name = "cratedigger.js";
      }
    ];
  };
}
