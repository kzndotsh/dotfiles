# micro — settings live in the store; ConfigDir is ~/.config/micro.
# -config-dir cannot be the store: 2.0.15 always mkdir ConfigDir/backups on save
# (atomic overwrite), even when backup is false.
{ pkgs, ... }:
let
  settings = pkgs.writeText "settings.json" ''
    {
      "colorscheme": "tokyonight",
      "tabsize": 2,
      "tabstospaces": true,
      "autoindent": true,
      "keepautoindent": true,
      "savecursor": true,
      "saveundo": true,
      "savehistory": true,
      "backup": true,
      "backupdir": "~/.config/micro/backups",
      "scrollbar": false,
      "rmtrailingws": true,
      "softwrap": true,
      "wordwrap": true,
      "cursorline": true,
      "autoclose": true,
      "hlsearch": true,
      "hltrailingws": true,
      "diffgutter": true,
      "clipboard": "external",
      "mkparents": true,
      "multiopen": "tab",
      "matchbrace": true,
      "matchbracestyle": "highlight",
      "incsearch": true,
      "scrollmargin": 5,
      "statusformatr": "$(opt:filetype) | Ln $(line), Col $(col) | tab:$(opt:tabsize) | $(opt:encoding) | $(opt:fileformat)",
      "statusformatl": "$(filename) $(modified) | $(lines) lines | $(status.branch)"
    }
  '';

  bindings = pkgs.writeText "bindings.json" ''
    {
      "Ctrl-/": "lua:comment.comment",
      "Ctrl-d": "SpawnMultiCursor",
      "Alt-Up": "MoveLinesUp",
      "Alt-Down": "MoveLinesDown",
      "Ctrl-Shift-k": "DeleteLine",
      "Ctrl-l": "SelectLine",
      "Ctrl-Shift-d": "DuplicateLine"
    }
  '';

  scheme = pkgs.writeText "tokyonight.micro" ''
    color-link default "#a9b1d6,#1a1b26"
    color-link comment "#565f89"
    color-link comment.bright "#737aa2"
    color-link identifier "#7aa2f7"
    color-link identifier.class "#7dcfff"
    color-link identifier.macro "#bb9af7"
    color-link identifier.var "#c0caf5"
    color-link constant "#e0af68"
    color-link constant.number "#ff9e64"
    color-link constant.string "#9ece6a"
    color-link constant.string.url "underlined #7aa2f7"
    color-link constant.bool "#ff9e64"
    color-link constant.bool.true "#ff9e64"
    color-link constant.bool.false "#ff9e64"
    color-link constant.specialChar "#7dcfff"
    color-link symbol "#89ddff"
    color-link symbol.operator "#89ddff"
    color-link symbol.brackets "#c0caf5"
    color-link symbol.tag "#f7768e"
    color-link statement "#bb9af7"
    color-link preproc "#7dcfff"
    color-link preproc.shebang "#565f89"
    color-link type "#2ac3de"
    color-link type.keyword "#bb9af7"
    color-link special "#f7768e"
    color-link underlined "underlined #7aa2f7"
    color-link error "bold #f7768e"
    color-link todo "bold #e0af68"
    color-link statusline "#a9b1d6,#16161e"
    color-link statusline.inactive "#565f89,#16161e"
    color-link statusline.suggestions "#a9b1d6,#292e42"
    color-link tabbar "#565f89,#16161e"
    color-link tabbar.active "#a9b1d6,#1a1b26"
    color-link indent-char "#3b4261"
    color-link line-number "#3b4261"
    color-link current-line-number "#737aa2"
    color-link gutter-error "#f7768e"
    color-link gutter-warning "#e0af68"
    color-link gutter-info "#7aa2f7"
    color-link cursor-line "#292e42"
    color-link color-column "#292e42"
    color-link match-brace "bold #7aa2f7,#3b4261"
    color-link hlsearch "#1a1b26,#e0af68"
    color-link selection "#c0caf5,#3b4261"
    color-link diff-added "#9ece6a"
    color-link diff-modified "#e0af68"
    color-link diff-deleted "#f7768e"
    color-link scrollbar "#3b4261"
    color-link divider "#3b4261"
    color-link message "#7aa2f7"
    color-link error-message "#f7768e"
    color-link trailingws ",#f7768e"
    color-link tab-error ",#db4b4b"
    color-link ignore "#565f89"
  '';

  # preRun values must be a single argv token (nix-wrappers does not quote --run).
  linkConfig = pkgs.writeShellScript "micro-link-config" ''
    cfg="''${XDG_CONFIG_HOME:-$HOME/.config}/micro"
    mkdir -p "$cfg/colorschemes"
    ln -sfn ${settings} "$cfg/settings.json"
    ln -sfn ${bindings} "$cfg/bindings.json"
    ln -sfn ${scheme} "$cfg/colorschemes/tokyonight.micro"
  '';
in
{
  wrappers.micro = {
    basePackage = pkgs.micro;
    systemWide = true;
    executables.micro = {
      preRun = [ "${linkConfig}" ];
    };
  };
}
