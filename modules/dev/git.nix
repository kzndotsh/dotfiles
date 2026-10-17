# Git — delta pager, Cursor commit editor, 1Password SSH signing, gh credential helper, LFS.
{ pkgs, lib, config, ... }:
let
  globalExcludes = pkgs.writeText "git-global-excludes" ''
    # OS
    .DS_Store
    Thumbs.db
    desktop.ini

    # Editors
    *~
    *.swp
    *.swo

    # Nix / direnv
    .direnv/
    result
  '';

  home = config.my.home;
  signingProgram = "/run/current-system/sw/bin/op-ssh-sign";
  identityText = lib.generators.toGitINI {
    user = {
      name = config.my.gitName;
      email = config.my.gitEmail;
      signingkey = "~/.ssh/id_ed25519.pub";
    };
    gpg.format = "ssh";
    "gpg \"ssh\"" = {
      program = signingProgram;
      allowedSignersFile = "~/.config/git/allowed_signers";
    };
    commit.gpgsign = true;
  };
  allowedSigners = "${config.my.gitEmail} namespaces=\"git\" ${config.my.sshKey}\n";
  # tmpfiles `f` arguments take C escapes, one line per rule.
  tmpfilesText = s: builtins.replaceStrings [ "\\" "\n" "\t" ] [ "\\\\" "\\n" "\\t" ] s;
in
{
  programs.git = {
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
          editor = "cursor --reuse-window --wait";
          autocrlf = "input";
          pager = "delta";
          excludesfile = globalExcludes;
          # Git's fsmonitor daemon misses Cursor/agent writes, so status/diff
          # keep a stale index and hide dirty files. Do not re-enable.
          fsmonitor = false;
          untrackedCache = false;
        };
        column.ui = "auto";
        init.defaultBranch = "main";
        branch = {
          autoSetupRebase = "always";
          sort = "-committerdate";
        };
        tag.sort = "version:refname";
        pull.rebase = true;
        rebase = {
          autoStash = true;
          autoSquash = true;
          updateRefs = true;
          missingCommitsCheck = "error";
        };
        push = {
          autoSetupRemote = true;
          default = "current";
          followTags = true;
        };
        fetch = {
          prune = true;
          pruneTags = true;
          all = true;
        };
        merge = {
          conflictstyle = "zdiff3";
          ff = "only";
          log = true;
        };
        interactive.diffFilter = "delta --color-only";
        rerere = {
          enabled = true;
          autoUpdate = true;
        };
        color.ui = true;
        diff = {
          algorithm = "histogram";
          colorMoved = "default";
          mnemonicPrefix = true;
          renames = true;
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
        "gpg \"ssh\"" = {
          program = signingProgram;
          # lets `git log --show-signature` / verify-commit trust our own SSH signatures
          allowedSignersFile = "~/.config/git/allowed_signers";
        };
        status = {
          showUntrackedFiles = "all";
          branch = true;
        };
        log = {
          decorate = "auto";
          abbrevCommit = true;
          date = "relative";
        };
        grep.patternType = "perl";
        protocol.version = 2;
        help.autocorrect = "prompt";
        credential.helper = "!/run/current-system/sw/bin/gh auth git-credential";
        "url \"ssh://git@github.com/\"".insteadOf = "https://github.com/";
        alias = {
          a = "add";
          c = "commit";
          p = "push";
          s = "status -s";
          d = "diff";
          dw = "-c delta.side-by-side=false diff";
          l = "log --oneline --graph --decorate --all";
          co = "checkout";
          sw = "switch";
          swc = "switch -c";
          cm = "commit -m";
          ca = "commit --amend";
          can = "commit --amend --no-edit";
          aa = "add -A";
          dc = "diff --cached";
          pf = "push --force-with-lease";
          pl = "pull";
          up = "pull --rebase";
          undo = "reset HEAD~1";
          fixup = "commit --fixup";
          squash = "commit --squash";
          wip = "commit -am WIP";
          unstage = "restore --staged";
          discard = "restore";
        };
      }
    ];
  };

  environment.systemPackages = with pkgs; [ delta gh ];

  # Global-scope copy of identity + signing. Some apps only read ~/.config/git/config, and the
  # Claude desktop sandbox can't see /etc/gitconfig (a NixOS symlink into /etc/static) at all.
  # tmpfiles rewrites these real files on every switch; config itself stays user-writable.
  systemd.tmpfiles.rules = [
    "d ${home}/.config/git 0755 ${config.my.username} users -"
    "f+ ${home}/.config/git/identity 0644 ${config.my.username} users - ${tmpfilesText identityText}"
    "f+ ${home}/.config/git/allowed_signers 0644 ${config.my.username} users - ${tmpfilesText allowedSigners}"
    "f ${home}/.config/git/config 0644 ${config.my.username} users - [include]\\n\\tpath = identity\\n"
  ];
}
