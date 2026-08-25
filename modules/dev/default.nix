{ pkgs, config, ... }:
{
  imports = [ ./cursor.nix ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      silent = true;
    };

    git = {
      enable = true;
      lfs.enable = true;
      package = pkgs.git;
      config = [
        {
          user = {
            name = config.my.gitName;
            email = config.my.gitEmail;
            username = config.my.gitUsername;
            signingkey = "~/.ssh/id_ed25519.pub";
          };
          core = {
            editor = "micro";
            autocrlf = "input";
            pager = "delta";
          };
          init.defaultBranch = "main";
          branch = {
            autoSetupRebase = "always";
            sort = "-committerdate";
          };
          pull.rebase = true;
          rebase = {
            autoStash = true;
            autoSquash = true;
          };
          push = {
            autoSetupRemote = true;
            default = "current";
            followTags = true;
          };
          fetch = {
            prune = true;
            pruneTags = true;
          };
          merge = {
            conflictstyle = "diff3";
            ff = false;
          };
          rerere = {
            enabled = true;
            autoUpdate = true;
          };
          color.ui = true;
          diff = {
            algorithm = "histogram";
            colorMoved = "default";
            tool = "delta";
          };
          delta = {
            true-color = "always";
            line-numbers = true;
            side-by-side = true;
            navigate = true;
            light = false;
            minus-style = "syntax \"#4a272f\"";
            minus-non-emph-style = "syntax \"#4a272f\"";
            minus-emph-style = "syntax \"#713137\"";
            minus-empty-line-marker-style = "syntax \"#4a272f\"";
            line-numbers-minus-style = "#914c54";
            plus-style = "syntax \"#243e4a\"";
            plus-non-emph-style = "syntax \"#243e4a\"";
            plus-emph-style = "syntax \"#2c5a66\"";
            plus-empty-line-marker-style = "syntax \"#243e4a\"";
            line-numbers-plus-style = "#449dab";
            line-numbers-zero-style = "#3b4261";
          };
          commit = {
            verbose = true;
            gpgsign = true;
          };
          gpg.format = "ssh";
          "gpg \"ssh\"".program = "/run/current-system/sw/bin/op-ssh-sign";
          status = {
            showUntrackedFiles = "all";
            branch = true;
          };
          log = {
            decorate = "auto";
            abbrevCommit = true;
            date = "relative";
          };
          protocol.version = 2;
          help.autocorrect = 1;
          credential.helper = "!/run/current-system/sw/bin/gh auth git-credential";
          "url \"ssh://git@github.com/\"".insteadOf = "https://github.com/";
          alias = {
            a = "add";
            c = "commit";
            p = "push";
            s = "status -s";
            d = "diff";
            l = "log --oneline --graph --decorate --all";
            co = "checkout";
            sw = "switch";
            swc = "switch -c";
            cm = "commit -m";
            ca = "commit --amend";
            can = "commit --amend --no-edit";
            aa = "add -A";
            dc = "diff --cached";
            lg = "log --oneline --graph --decorate --all";
            pf = "push --force-with-lease";
            pl = "pull";
            up = "pull --rebase";
            undo = "reset HEAD~1";
          };
        }
      ];
    };
  };

  environment.systemPackages = with pkgs; [ delta gh ];
}
