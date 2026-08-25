{ pkgs, inputs, ... }:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  # Do not also put pkgs.spotify in systemPackages — this module installs it.
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
