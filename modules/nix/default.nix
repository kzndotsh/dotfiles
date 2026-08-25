{ config, inputs, lib, ... }:
{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      max-jobs = "auto";
      cores = 0;
      auto-optimise-store = true;
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
      substituters = [
        "https://cache.nixos.org?priority=10"
        "https://nix-community.cachix.org"
        "https://comfyui.cachix.org"
        "https://cuda-maintainers.cachix.org"
        "https://ai.cachix.org"
        "https://nixpkgs-unfree.cachix.org"
        "https://nix-gaming.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "comfyui.cachix.org-1:33mf9VzoIjzVbp0zwj+fT51HG0y31ZTK3nzYZAX0rec="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
        "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lnWidTl2AKRkC28oag="
        "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      ];
    };

    # Cleanup is handled by programs.nh.clean, not the nix-daemon GC timer.
    gc.automatic = false;

    # Register flake inputs so `nix run nixpkgs#foo` resolves instantly.
    registry = lib.mapAttrs (_: v: { flake = v; }) (
      lib.filterAttrs (_: v: lib.isType "flake" v) inputs
    );

    # Legacy `nix-env -i` and friends still read nixPath; point them at the same registry.
    nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") config.nix.registry;
  };
}
