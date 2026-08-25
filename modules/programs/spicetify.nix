{ pkgs, inputs, ... }:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  # This module installs Spotify — do not also add pkgs.spotify to systemPackages.
  programs.spicetify = {
    enable = true;
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
