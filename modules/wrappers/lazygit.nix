# lazygit — Tokyo Night (night) theme + delta pager (matches programs.git).
# Theme from folke/tokyonight.nvim extras/lazygit/tokyonight_night.yml
{ pkgs, ... }:
let
  deltaHyperlinks = ''--line-numbers --hyperlinks --hyperlinks-file-link-format=lazygit-edit://{path}:{line}'';
  configFile = pkgs.writeText "lazygit-config.yml" ''
    gui:
      nerdFontsVersion: "3"
      border: rounded
      wrapLinesInStagingView: true
      theme:
        activeBorderColor:
          - "#ff9e64"
          - bold
        inactiveBorderColor:
          - "#27a1b9"
        searchingActiveBorderColor:
          - "#ff9e64"
          - bold
        optionsTextColor:
          - "#7aa2f7"
        selectedLineBgColor:
          - "#283457"
        inactiveViewSelectedLineBgColor:
          - "#1f2335"
        cherryPickedCommitFgColor:
          - "#7aa2f7"
        cherryPickedCommitBgColor:
          - "#bb9af7"
        markedBaseCommitFgColor:
          - "#7aa2f7"
        markedBaseCommitBgColor:
          - "#e0af68"
        unstagedChangesColor:
          - "#db4b4b"
        defaultFgColor:
          - "#c0caf5"

    os:
      editPreset: micro

    git:
      diffRenderers:
        - name: unified
          command: env DELTA_FEATURES=-side-by-side delta --dark --paging=never ${deltaHyperlinks}
        - name: side-by-side
          command: delta --dark --paging=never ${deltaHyperlinks}
      mainBranches:
        - main
        - master
        - develop
        - trunk
      parseEmoji: true
      autoForwardBranches: onlyMainBranches
      log:
        order: topo-order
        showGraph: always
  '';
in
{
  wrappers.lazygit = {
    basePackage = pkgs.lazygit;
    systemWide = true;
    executables.lazygit = {
      args.prefix = [ "--use-config-file=${configFile}" ];
    };
  };
}
