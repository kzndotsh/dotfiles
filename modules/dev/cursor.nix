# Cursor — argv.json + dotfiles worktree config via tmpfiles (store symlinks).
# Desktop only (via modules/dev/). VM/VPS do not import this dir.
{ pkgs, config, ... }:
let
  inherit (config.my) dotfilesDir home;

  argvJson = pkgs.writeText "cursor-argv.json" ''
    {"password-store":"gnome-libsecret"}
  '';

  setupWorktreeUnix = pkgs.writeScript "cursor-setup-worktree-unix.sh" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

    echo "cursor worktree setup: $(pwd)"

    if command -v direnv >/dev/null 2>&1; then
      direnv allow
      if direnv export bash >/dev/null 2>&1; then
        eval "$(direnv export bash)"
      fi
    fi

    nix flake check --no-build

    if command -v statix >/dev/null 2>&1; then
      statix check .
    fi

    if command -v deadnix >/dev/null 2>&1; then
      deadnix . --exclude references archive
    fi

    if [[ -n "''${ROOT_WORKTREE_PATH:-}" && -f "''${ROOT_WORKTREE_PATH}/.env.kzn" && ! -f .env.kzn ]]; then
      cp "''${ROOT_WORKTREE_PATH}/.env.kzn" .env.kzn
    fi

    echo "cursor worktree setup complete"
  '';

  worktreesJson = pkgs.writeText "cursor-worktrees.json" (
    builtins.toJSON {
      "setup-worktree-unix" = "setup-worktree-unix.sh";
    }
  );

  # Cursor 3.x may skip worktrees.json setup — rule forces agents to run it anyway.
  worktreeMdc = pkgs.writeText "cursor-worktree.mdc" ''
    ---
    description: Mandatory setup when using Cursor parallel git worktrees — run before any task work in a worktree checkout
    alwaysApply: false
    ---

    # Cursor worktree setup (mandatory)

    If you are in a **parallel git worktree** (path under `~/.cursor/worktrees/`) or the user invoked `/worktree`:

    1. Locate `.cursor/worktrees.json` — check `$DOTFILES_DIR/.cursor/` or `$ROOT_WORKTREE_PATH/.cursor/` when set.
    2. Run the configured setup (`setup-worktree-unix.sh` or every command in the JSON) **before** editing, committing, or running build commands.
    3. Verify setup succeeded: `direnv` allowed, `nix flake check --no-build` passes.

    Do **not** assume the worktree inherited direnv, `.env.kzn`, or flake checks from the main checkout.

    When the user runs `/worktree`, state in your plan that worktree setup runs first per this rule.
  '';
in
{
  environment.variables = {
    DOTFILES_DIR = dotfilesDir;
  };

  systemd.tmpfiles.rules = [
    "d ${home}/.config/Cursor 0755 ${config.my.username} users -"
    "L+ ${home}/.config/Cursor/argv.json - - - - ${argvJson}"
    "d ${dotfilesDir}/.cursor 0755 ${config.my.username} users -"
    "d ${dotfilesDir}/.cursor/rules 0755 ${config.my.username} users -"
    "L+ ${dotfilesDir}/.cursor/worktrees.json - - - - ${worktreesJson}"
    "L+ ${dotfilesDir}/.cursor/setup-worktree-unix.sh - - - - ${setupWorktreeUnix}"
    "L+ ${dotfilesDir}/.cursor/rules/worktree.mdc - - - - ${worktreeMdc}"
  ];
}
