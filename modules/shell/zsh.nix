# Zsh configuration. Reference: nixos/modules/programs/zsh/zsh.nix
#
# NixOS enables completion by default (nix-zsh-completions + /share/zsh on fpath).
# Default setOptions include HIST_IGNORE_DUPS, SHARE_HISTORY, and HIST_FCNTL_LOCK.
# SHARE_HISTORY already appends incrementally — do not also set INC_APPEND_HISTORY (they conflict).
# Syntax highlighting runs mkAfter on interactiveShellInit; promptInit comes after that.
# Init order in our mkAfter block: FZF_DEFAULT_OPTS → vivid/mise/zoxide/functions → fzf-tab (Tab last).
{ pkgs, lib, ... }:
let
  # Minimal prompt when Cursor Agent runs shell commands (cursor.com/docs/agent/tools/terminal).
  cursorAgentStarship = pkgs.writeText "starship-cursor-agent.toml" ''
    add_newline = false
    format = "$directory$character"
    directory.truncation_length = 1
    directory.style = "bold #7aa2f7"
    character.success_symbol = "[❯](bold #7aa2f7)"
    character.error_symbol = "[❯](bold #db4b4b)"
  '';
in
{
  programs.zsh = {
    enable = true;
    # Skip the first-run wizard if ~/.zshrc is missing.
    shellInit = ''
      zsh-newuser-install() { :; }
      if [[ -n "$CURSOR_AGENT" ]]; then
        export STARSHIP_CONFIG=${cursorAgentStarship}
      fi
      # Non-interactive shells (Cursor agent `zsh -c`) skip interactiveShellInit — hook direnv here.
      if command -v direnv >/dev/null 2>&1; then
        eval "$(direnv hook zsh)"
      fi
    '';

    # We run our own cached compinit below instead of NixOS's global one.
    enableGlobalCompInit = false;
    # NixOS would run dircolors after interactiveShellInit and overwrite vivid's LS_COLORS.
    enableLsColors = false;

    autosuggestions = {
      enable = true;
      # History-first is faster; completion-first almost always wins and feels sluggish.
      strategy = [ "history" "completion" ];
      highlightStyle = "fg=#565f89";
      extraConfig.ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE = "20";
    };
    syntaxHighlighting = {
      enable = true;
      # NixOS and the plugin default to main-only highlighting.
      highlighters = [ "main" "brackets" ];
    };

    # NixOS defaults are histSize 2000 and histFile $HOME/.zsh_history.
    histSize = 1000000000;
    histFile = "$XDG_CACHE_HOME/zsh_history";
    # This option replaces the whole list — re-include NixOS defaults plus our extras.
    setOptions = [
      "HIST_IGNORE_DUPS"
      "SHARE_HISTORY"
      "HIST_FCNTL_LOCK"
      "HIST_IGNORE_SPACE"
      "HIST_REDUCE_BLANKS"
      "HIST_FIND_NO_DUPS"
      "INTERACTIVE_COMMENTS"
      "NO_FLOW_CONTROL"
    ];

    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "ga" = "git add";
      "gc" = "git commit";
      "gpu" = "git push";
      "gpl" = "git pull";
      "gs" = "git status";
      "gd" = "git diff";
      "l" = "eza -lh --icons --git --group-directories-first --color=auto --header --octal-permissions";
      "ls" = "eza --icons --group-directories-first --color=auto";
      "ll" = "eza -l --icons --git --group-directories-first --color=auto --header";
      "la" = "eza -la --icons --git --group-directories-first --color=auto --header";
      "tree" = "eza --tree --icons --group-directories-first --color=auto";
      "c" = "clear";
      "x" = "exit";
      "q" = "exit";
      "dc" = "docker compose";
      "dps" = "docker ps";
      "dexec" = "docker exec -it";
      emptydirs = "find . -type d -empty -delete";
    };

    interactiveShellInit = lib.mkMerge [
      ''
        autoload -Uz compinit
        _comp_cache="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
        mkdir -p "$XDG_CACHE_HOME/zsh"
        if [[ -f "$_comp_cache" ]] && (( $(date +%s) - $(stat -c %Y "$_comp_cache") < 86400 )); then
          compinit -C -d "$_comp_cache"
        else
          compinit -d "$_comp_cache"
        fi
        unset _comp_cache

        zstyle ':completion:*' completer _extensions _complete _approximate
        zstyle ':completion:*' use-cache on
        zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
        # fzf-tab needs menu no so it can capture the unambiguous prefix (not menu select).
        zstyle ':completion:*' menu no
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
        zstyle ':completion:*' group-name '''
        # fzf-tab does not expand %F/%B prompt codes — they show up as literal text.
        zstyle ':completion:*:descriptions' format '[%d]'
        zstyle ':completion:*:warnings' format '[no matches]'
        zstyle ':completion:*:corrections' format '[%d (errors: %e)]'
        zstyle ':completion:*' squeeze-slashes true
        zstyle ':completion:*' file-sort modification
        zstyle ':completion:*:kill:*' force-list always
        zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

        # Use zsh inside nix-shell. Completions already come from enableCompletion.
        source ${pkgs.zsh-nix-shell}/share/zsh-nix-shell/nix-shell.plugin.zsh
        # Plugin sets NIX_SHELL_PLUGIN_DIR=''${0:a:h} at source time; $0 is wrong when
        # zshrc is sourced by non-interactive shells → /scripts/buildShellShim breakage.
        export NIX_SHELL_PLUGIN_DIR=${pkgs.zsh-nix-shell}/share/zsh-nix-shell

        # Default WORDCHARS includes / and . so emacs-word / Ctrl-W eat whole paths.
        WORDCHARS="''${WORDCHARS//[\/.]}"

        bindkey '^[[1;5C' emacs-forward-word
        bindkey '^[[1;5D' emacs-backward-word
      ''
      # After programs.fzf.fuzzyCompletion binds ^I (no mkAfter in nixpkgs fzf.nix).
      # fzf-tab goes last so it owns Tab. FZF_DEFAULT_OPTS is set first (plugin reads it at Tab).
      (lib.mkAfter ''
        export FZF_DEFAULT_OPTS="--highlight-line --info=inline-right --ansi --layout=reverse --border=none --color=bg+:#283457 --color=bg:#16161e --color=border:#27a1b9 --color=fg:#c0caf5 --color=gutter:#16161e --color=header:#ff9e64 --color=hl+:#2ac3de --color=hl:#2ac3de --color=info:#545c7e --color=marker:#ff007c --color=pointer:#ff007c --color=prompt:#2ac3de --color=query:#c0caf5:regular --color=scrollbar:#27a1b9 --color=separator:#ff9e64 --color=spinner:#ff007c"

        export PATH="$XDG_DATA_HOME/npm/bin:$PATH"

        if command -v vivid >/dev/null; then
          export LS_COLORS="$(vivid generate tokyonight-night)"
        fi
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"

        eval "$(mise activate zsh)"
        eval "$(zoxide init zsh --cmd cd)"

        group_videos() {
          local video_dir="videos"
          mkdir -p "$video_dir"
          local video_extensions=(mp4 avi mkv 3gp mov flv wmv mpg mpeg webm m4v)
          for ext in "''${video_extensions[@]}"; do
            find . -maxdepth 1 -type f -iname "*.$ext" -exec mv -nv {} "$video_dir/" \;
          done
        }

        group_images() {
          local image_dir="images"
          mkdir -p "$image_dir"
          local image_extensions=(jpg jpeg png gif bmp tiff svg webp heif heic)
          for ext in "''${image_extensions[@]}"; do
            find . -maxdepth 1 -type f -iname "*.$ext" -exec mv -nv {} "$image_dir/" \;
          done
        }

        mvwithsuffix() {
          local src_dir=$1
          local dest_dir=$2

          if [ -z "$src_dir" ] || [ -z "$dest_dir" ]; then
            echo "Usage: mvwithsuffix <source-directory> <destination-directory>"
            return 1
          fi

          if [ ! -d "$src_dir" ]; then
            echo "Source directory '$src_dir' does not exist."
            return 1
          fi

          mkdir -p "$dest_dir"

          for file in "$src_dir"/*; do
            if [ -f "$file" ]; then
              local filename=$(basename "$file")
              local dest_file="$dest_dir/$filename"

              if [ -e "$dest_file" ]; then
                local counter=1
                local new_filename="''${filename%.*}_''${counter}.''${filename##*.}"
                local new_dest_file="$dest_dir/$new_filename"

                while [ -e "$new_dest_file" ]; do
                  counter=$((counter + 1))
                  new_filename="''${filename%.*}_''${counter}.''${filename##*.}"
                  new_dest_file="$dest_dir/$new_filename"
                done

                mv "$file" "$new_dest_file"
              else
                mv "$file" "$dest_file"
              fi
            fi
          done
        }

        flattendir() {
          find . -mindepth 2 -type f | while IFS= read -r file; do
            local base=$(basename "$file")

            if [[ -e "./$base" ]]; then
              local number=1
              while [[ -e "./''${number}_$base" ]]; do
                number=$((number + 1))
              done
              mv -nv "$file" "./''${number}_$base"
            else
              mv -nv "$file" .
            fi
          done
        }

        list_file_extensions() {
          find . -type f | sed -n 's/.*\.\([^.]*\)$/\1/p' | sort -u
        }

        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
        zstyle ':fzf-tab:*' use-fzf-default-opts yes
        zstyle ':fzf-tab:*' fzf-flags --height=40% --layout=reverse --border
        zstyle ':fzf-tab:*' switch-group '<' '>'
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath'
        zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
        zstyle ':fzf-tab:complete:git-*:*' fzf-preview 'git diff --color=always $word 2>/dev/null || git log --oneline --color=always -5 $word 2>/dev/null'
      '')
    ];

    # Runs after syntax-highlighting (NixOS mkAfter on interactiveShellInit).
    promptInit = ''
      source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
      bindkey '^[OA' history-substring-search-up
      bindkey '^[OB' history-substring-search-down
      bindkey '^[[1;5A' history-substring-search-up
      bindkey '^[[1;5B' history-substring-search-down
    '';
  };
}
