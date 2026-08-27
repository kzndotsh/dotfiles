# Shell barrel: starship prompt, fzf, and CLI tools. Zsh-specific config is in zsh.nix.
{ pkgs, ... }:
{
  imports = [ ./zsh.nix ];

  environment.systemPackages = with pkgs; [
    eza
    httpie
    python3Packages.ipython
    vivid
    zoxide
    mise
  ];

  programs = {
    starship = {
      enable = true;
      settings = {
        command_timeout = 1000;
        format = "$os$directory$git_branch$git_state$git_status$git_commit$nix_shell$cmd_duration\n$character";
        add_newline = true;
        os = { disabled = false; style = "bold #7dcfff"; };
        directory = {
          style = "bold #7aa2f7";
          truncation_length = 0;
          truncate_to_repo = false;
        };

        # Git — read left-to-right: branch → in-progress op → local changes → remote sync → detached hash
        git_branch = {
          symbol = "⎇ ";
          style = "bold #73daca";
          format = " [$symbol$branch]($style)";
        };
        git_state = {
          style = "bold #ff9e64";
          format = " · [$state $progress_current/$progress_total]($style)";
          rebase = "rebasing";
          merge = "merging";
          cherry_pick = "cherry-picking";
          revert = "reverting";
          bisect = "bisecting";
        };
        git_status = {
          style = "#e0af68";
          format = "[$all_status$ahead_behind]($style)";
          conflicted = " · [\${count} conflict](bold #f7768e)";
          staged = " · [\${count} staged](bold #9ece6a)";
          modified = " · [\${count} changed]($style)";
          untracked = " · [\${count} new]($style)";
          renamed = " · [\${count} renamed]($style)";
          deleted = " · [\${count} deleted]($style)";
          stashed = " · [stash]($style)";
          ahead = " · [↑\${count} ahead](bold #7dcfff)";
          behind = " · [↓\${count} behind](bold #7dcfff)";
          diverged = " · [↕ \${ahead_count}↑ \${behind_count}↓](bold #ff9e64)";
        };
        git_commit = {
          style = "#565f89";
          commit_hash_length = 7;
          only_detached = true;
          format = " · [detached @ $hash$tag]($style)";
        };

        # Shown when direnv loads a flake dev shell (IN_NIX_SHELL).
        nix_shell = {
          style = "#bb9af7";
          impure_msg = "nix flake";
          pure_msg = "nix pure";
          format = " · [$state]($style)";
        };
        cmd_duration = { style = "#565f89"; min_time = 2000; format = "[$duration]($style) "; };
        character = { success_symbol = "[❯](bold #7aa2f7)"; error_symbol = "[❯](bold #db4b4b)"; };
      };
    };

    nix-index.enable = true;
    fzf = { keybindings = true; fuzzyCompletion = true; };
  };
}
