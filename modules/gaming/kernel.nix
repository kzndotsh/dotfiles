# SteamOS-style sysctl tuning and ntsync module load. Gated by gaming.enable — not hardware/.
# GPU drivers, LACT, and RADV settings stay in modules/hardware/.
#
# Do not import nix-gaming platformOptimizations wholesale — it overrides vm.max_map_count
# (boot/sysctl.nix already sets 1048576; Star Citizen mkForce lives in games.nix).
#
# ntsync is a kernel module (≥6.14). programs.wine.ntsync lives in modules/wine/.
#
# Optional kernel cmdline tweaks (add in boot/kernel.nix only if needed):
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
