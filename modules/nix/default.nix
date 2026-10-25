{ config, inputs, lib, ... }:
{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      max-jobs = "auto";
      cores = 0;
      builders-use-substitutes = true;
      keep-derivations = true;
      keep-outputs = true;
      trusted-users = [ "root" "@wheel" ];
      allowed-users = [ "@users" ];
      accept-flake-config = false;
      warn-dirty = false;
      use-xdg-base-directories = true;
      http-connections = 50;
      log-lines = 25;
      fallback = true;
      connect-timeout = 5;
      # cache.nixos.org comes from the NixOS default; each extra cache adds a lookup per missing path.
      substituters = [
        "https://nix-community.cachix.org"
        "https://nix-gaming.cachix.org"
        "https://cache.numtide.com"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };

    # Cleanup is handled by programs.nh.clean, not the nix-daemon GC timer.
    gc.automatic = false;

    # Weekly hardlink dedupe instead of auto-optimise-store, which slows every store write.
    optimise.automatic = true;

    # Register flake inputs so `nix run nixpkgs#foo` resolves instantly.
    registry = lib.mapAttrs (_: v: { flake = v; }) (
      lib.filterAttrs (_: v: lib.isType "flake" v) inputs
    );

    # Legacy `nix-env -i` and friends still read nixPath; point them at the same registry.
    nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") config.nix.registry;
  };
}
