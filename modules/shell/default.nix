# Barrel: prompt + fuzzy finder. Zsh-specific config is zsh.nix.
{ pkgs, ... }:
{
  imports = [ ./zsh.nix ];

  environment.systemPackages = with pkgs; [
    eza
    vivid
    zoxide
    mise
  ];

  programs = {
    starship = {
      enable = true;
      settings = {
        format = "$os$directory$git_branch$git_commit$git_state$git_status$nix_shell$cmd_duration\n$character";
        add_newline = true;
        os = { disabled = false; style = "bold #7dcfff"; };
        directory = { style = "bold #7aa2f7"; truncation_length = 3; truncation_symbol = "…/"; };
        git_branch = { symbol = " "; style = "bold #73daca"; format = "[$symbol$branch]($style) "; };
        git_status = { style = "#e0af68"; format = "[$all_status$ahead_behind]($style) "; conflicted = "~\${count} "; modified = "!\${count} "; staged = "+\${count} "; untracked = "?\${count} "; };
        git_commit = { style = "#565f89"; commit_hash_length = 7; only_detached = true; format = "[$hash$tag]($style) "; };
        git_state = { style = "bold #ff9e64"; format = "\\([$state( $progress_current/$progress_total)]($style)\\) "; };
        nix_shell = { symbol = " "; style = "#bb9af7"; format = "[$symbol$state( \\($name\\))]($style) "; };
        cmd_duration = { style = "#565f89"; min_time = 2000; format = "[$duration]($style) "; };
        character = { success_symbol = "[❯](bold #7aa2f7)"; error_symbol = "[❯](bold #db4b4b)"; };
      };
    };

    nix-index.enable = true;
    fzf = { keybindings = true; fuzzyCompletion = true; };
  };
}
