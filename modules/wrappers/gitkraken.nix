# GitKraken — keyring for OAuth/integration tokens, plus profile settings merged on every launch.
# Git identity, signing and SSH come from ~/.config/git (modules/dev/git.nix) and the session
# SSH_AUTH_SOCK; Wayland flags from the package.
{ lib, pkgs, config, ... }:
let
  # GitKraken substitutes $REPO_PATH / $FILE_PATH as whole args and spawns without a cwd.
  # Single-instance Ghostty would open in its own cwd, so force a fresh instance.
  open = pkgs.writeShellScript "gitkraken-open" ''
    launch() { exec ghostty --gtk-single-instance=false --working-directory="$1" "''${@:2}"; }
    case "$1" in
      file) launch "$2" -e micro "$3" ;;
      repo) launch "$2" -e micro ;;
      terminal) launch "$2" ;;
    esac
  '';

  # Only these keys are managed; everything else in the profile stays app-owned.
  # Must match GitKraken's system font list exactly (Chromium quotes multi-word families), else it resets.
  monoFont = ''"JetBrainsMono Nerd Font Mono"'';

  settings = pkgs.writeText "gitkraken-profile.json" (builtins.toJSON {
    autoFetchInterval = 5;
    pullType = "pull_rebase";
    init.defaultBranch = "main";
    gpg.userSigningKeySsh = "${config.my.home}/.ssh/id_ed25519.pub";
    cli = {
      fontFamily = monoFont;
      fontSize = 14;
      cursorStyle = "block";
    };
    editor = {
      fontFamily = monoFont;
      fontSize = 13;
      tabSize = 2;
      wordWrap = true;
    };
    fileView.diffDisplayMode = "split";
    externalTools = {
      editor = {
        externalEditorType = "custom";
        customEditor = {
          path = "${open}";
          commands = {
            file = "file $REPO_PATH $FILE_PATH";
            repo = "repo $REPO_PATH";
          };
        };
      };
      terminal = {
        externalTerminalType = "custom";
        customTerminal = {
          path = "${open}";
          command = "terminal $REPO_PATH";
        };
      };
    };
    ui = {
      theme = "dark";
      useAuthorInitialsForAvatars = true;
      graphOptions.columns = {
        "commit-author-zone".visible = true;
        "commit-date-time-zone".visible = true;
      };
    };
  });

  mergeSettings = pkgs.writeShellScript "gitkraken-merge-settings" ''
    for profile in "$HOME"/.gitkraken/profiles/*/profile; do
      [ -f "$profile" ] || continue
      [ -f "$profile.pre-nix" ] || cp "$profile" "$profile.pre-nix"
      ${lib.getExe pkgs.jq} -s '.[0] * .[1]' "$profile" ${settings} > "$profile.tmp" \
        && mv "$profile.tmp" "$profile"
    done
  '';
in
{
  wrappers.gitkraken = {
    basePackage = pkgs.gitkraken;
    systemWide = true;
    executables.gitkraken = {
      # Electron can't detect a keyring backend under Sway; the package rpath only has libgnome-keyring.
      args.prefix = [ "--password-store=gnome-libsecret" ];
      environment.LD_LIBRARY_PATH.prefix = [ (lib.makeLibraryPath [ pkgs.libsecret ]) ];
      preRun = [ "${mergeSettings}" ];
    };
  };
}
