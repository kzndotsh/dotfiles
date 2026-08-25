# SteamOS-style sysctl + ntsync module load. Gated by gaming.enable — not hardware/.
# GPU drivers / LACT / RADV stay in modules/hardware/.
#
# Do not import nix-gaming `platformOptimizations` wholesale — it overrides
# vm.max_map_count (boot/sysctl.nix already sets 1048576; Star Citizen mkForce
# in games.nix).
# https://github.com/fufexan/nix-gaming
# https://wiki.archlinux.org/title/Gaming
#
# ntsync is a kernel module (≥6.14). programs.wine.ntsync lives in modules/wine/.
# https://docs.kernel.org/driver-api/ntsync.html
#
# Optional cmdline (add only if needed, in boot/kernel.nix):
#   amdgpu.gpu_recovery=1 — auto-recover GPU hangs
#   amdgpu.ppfeaturemask=0xffff7fff — disable GFXOFF if idle freezes
{ config, lib, ... }:
let
  cfg = config.gaming;
  kernelVersion = config.boot.kernelPackages.kernel.version;
  ntsyncSupported = lib.versionAtLeast kernelVersion "6.14";
in
{
  config = lib.mkIf cfg.enable {
    boot.kernel.sysctl = {
      "kernel.sched_cfs_bandwidth_slice_us" = 3000;
      "kernel.split_lock_mitigate" = 0;
    };

    boot.kernelModules = lib.optionals ntsyncSupported [ "ntsync" ];
  };
}
