# btop-rocm with store-backed config and theme. There is no NixOS programs.btop option.
# --config and --themes-dir point at the store, so UI setting changes cannot persist.
{ pkgs, ... }:
let
  conf = pkgs.writeText "btop.conf" ''
    color_theme = "tokyonight"
    theme_background = false
    vim_keys = true
    rounded_corners = true
    update_ms = 1000
    proc_sorting = "cpu lazy"
    proc_tree = false
    proc_per_core = true
    show_gpu_info = true
    temp_scale = "fahrenheit"
  '';

  theme = pkgs.writeText "tokyonight.theme" ''
    theme[main_bg]="#1a1b26"
    theme[main_fg]="#c0caf5"
    theme[title]="#c0caf5"
    theme[hi_fg]="#ff9e64"
    theme[selected_bg]="#292e42"
    theme[selected_fg]="#7dcfff"
    theme[proc_misc]="#7dcfff"
    theme[cpu_box]="#27a1b9"
    theme[mem_box]="#27a1b9"
    theme[net_box]="#27a1b9"
    theme[proc_box]="#27a1b9"
    theme[div_line]="#27a1b9"
    theme[temp_start]="#9ece6a"
    theme[temp_mid]="#e0af68"
    theme[temp_end]="#f7768e"
    theme[cpu_start]="#9ece6a"
    theme[cpu_mid]="#e0af68"
    theme[cpu_end]="#f7768e"
    theme[free_start]="#9ece6a"
    theme[free_mid]="#e0af68"
    theme[free_end]="#f7768e"
    theme[cached_start]="#9ece6a"
    theme[cached_mid]="#e0af68"
    theme[cached_end]="#f7768e"
    theme[available_start]="#9ece6a"
    theme[available_mid]="#e0af68"
    theme[available_end]="#f7768e"
    theme[used_start]="#9ece6a"
    theme[used_mid]="#e0af68"
    theme[used_end]="#f7768e"
    theme[download_start]="#9ece6a"
    theme[download_mid]="#e0af68"
    theme[download_end]="#f7768e"
    theme[upload_start]="#9ece6a"
    theme[upload_mid]="#e0af68"
    theme[upload_end]="#f7768e"
  '';

  themesDir = pkgs.runCommand "btop-themes" { } ''
    mkdir -p $out
    ln -s ${theme} $out/tokyonight.theme
  '';
in
{
  wrappers.btop = {
    basePackage = pkgs.btop-rocm;
    systemWide = true;
    executables.btop = {
      args.prefix = [
        "--config"
        "${conf}"
        "--themes-dir"
        "${themesDir}"
      ];
    };
  };
}
