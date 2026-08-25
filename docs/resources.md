# Resources

External docs and tools that shaped this flake — useful if you are forking, debugging, or wondering *why* something is set up the way it is.

Links are grouped by topic, then by the Nix file they informed.

## Contents

- [Boot & kernel](#boot-kernel)
- [Security hardening](#security-hardening)
- [AI & local models](#ai-local-models)
- [Audio & PipeWire](#audio-pipewire)
- [Desktop](#desktop)
- [Sway & Wayland](#sway-wayland)
- [Development](#development)
- [Gaming](#gaming)
- [Music production](#music-production)
- [Programs](#programs)
- [Services](#services)
- [Wine](#wine)
- [CLI wrappers](#cli-wrappers)

## Boot & kernel

Kernel cmdline, sysctl, systemd-boot, zram, and power management.

- `modules/boot/kernel.nix`
  - [Arch Wiki — CPU frequency scaling (amd pstate)](https://wiki.archlinux.org/title/CPU_frequency_scaling#amd_pstate)
  - [Arch Wiki — PCI passthrough via OVMF](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF)
  - [Arch Wiki — Professional audio](https://wiki.archlinux.org/title/Professional_audio)
  - [freedesktop — systemd-udevd.service.html](https://www.freedesktop.org/software/systemd/man/latest/systemd-udevd.service.html)
  - [Kernel docs — amdgpu / module parameters](https://docs.kernel.org/gpu/amdgpu/module-parameters.html)
  - [Kernel docs — media / vivid](https://docs.kernel.org/admin-guide/media/vivid.html)
  - [Kernel docs — networking / ip sysctl](https://docs.kernel.org/networking/ip-sysctl.html)
  - [Kernel docs — pm / amd pstate](https://docs.kernel.org/admin-guide/pm/amd-pstate.html)
  - [Kernel docs — virt / kvm](https://docs.kernel.org/virt/kvm/)
  - [Kernel Self-Protection Project — recommended settings](https://kspp.github.io/Recommended_Settings.html)
  - [kernel.org — amd pstate](https://www.kernel.org/doc/html/v6.0/admin-guide/pm/amd-pstate.html)
  - [kernel.org — kernel parameters](https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html)
  - [NixOS Wiki — Linux kernel](https://wiki.nixos.org/wiki/Linux_kernel)
  - [NixOS/nixpkgs/master/nixos/modules/system/activation/top-level.nix](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/system/activation/top-level.nix)
  - [wiki.gentoo.org — Processor](https://wiki.gentoo.org/wiki/Power_management/Processor)
  - [zen-kernel/zen-kernel](https://github.com/zen-kernel/zen-kernel)
- `modules/boot/loader.nix`
  - [Arch Wiki — Systemd-boot](https://wiki.archlinux.org/title/Systemd-boot)
  - [Arch Wiki — Tmpfs](https://wiki.archlinux.org/title/Tmpfs)
  - [freedesktop — loader.conf.html](https://www.freedesktop.org/software/systemd/man/latest/loader.conf.html)
  - [freedesktop — systemd-boot.html](https://www.freedesktop.org/software/systemd/man/latest/systemd-boot.html)
  - [kernel.org — kernel parameters](https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html)
  - [uapi-group.org — boot loader specification](https://uapi-group.org/specifications/specs/boot_loader_specification)
- `modules/boot/power.nix`
  - [Arch Wiki — CPU frequency scaling (Autonomous frequency scaling)](https://wiki.archlinux.org/title/CPU_frequency_scaling#Autonomous_frequency_scaling)
  - [Arch Wiki — Gaming (Improving performance)](https://wiki.archlinux.org/title/Gaming#Improving_performance)
  - [Arch Wiki — NetworkManager (NetworkManager-wait-online)](https://wiki.archlinux.org/title/NetworkManager#NetworkManager-wait-online)
  - [Arch Wiki — Zram](https://wiki.archlinux.org/title/Zram)
  - [freedesktop — systemd-networkd-wait-online.service.html](https://www.freedesktop.org/software/systemd/man/latest/systemd-networkd-wait-online.service.html)
  - [Kernel docs — blockdev / zram](https://docs.kernel.org/admin-guide/blockdev/zram.html)
  - [Kernel docs — mm / transhuge](https://docs.kernel.org/admin-guide/mm/transhuge.html)
  - [Kernel docs — pm / amd pstate](https://docs.kernel.org/admin-guide/pm/amd-pstate.html)
  - [NixOS Wiki — Swap](https://wiki.nixos.org/wiki/Swap#Zram_swap)
  - [NixOS/nixpkgs/master/nixos/modules/config/sysfs.nix](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/config/sysfs.nix)
  - [NixOS/nixpkgs/master/nixos/modules/config/zram.nix](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/config/zram.nix)
  - [NixOS/nixpkgs/master/nixos/modules/tasks/cpu-freq.nix](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/tasks/cpu-freq.nix)
  - [redhat.com docs — configuring huge pages monitoring and managing system status and performance](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/monitoring_and_managing_system_status_and_performance/configuring-huge-pages_monitoring-and-managing-system-status-and-performance)
- `modules/boot/sysctl.nix`
  - [Arch Wiki — Gaming (Increase vm.max map count)](https://wiki.archlinux.org/title/Gaming#Increase_vm.max_map_count)
  - [Arch Wiki — Security (Kernel hardening)](https://wiki.archlinux.org/title/Security#Kernel_hardening) — Arch Security matches these two
  - [Arch Wiki — Sysctl](https://wiki.archlinux.org/title/Sysctl)
  - [Arch Wiki — Sysctl (TCP/IP stack hardening)](https://wiki.archlinux.org/title/Sysctl#TCP/IP_stack_hardening) — Arch TCP/IP stack hardening
  - [Arch Wiki — Sysctl (Virtual memory)](https://wiki.archlinux.org/title/Sysctl#Virtual_memory)
  - [Arch Wiki — Zram (Optimizing swap on zram)](https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram)
  - [fasterdata.es.net — linux](https://fasterdata.es.net/host-tuning/linux/)
  - [Kernel docs — admin guide / sysrq](https://docs.kernel.org/admin-guide/sysrq.html)
  - [Kernel docs — networking / ip sysctl](https://docs.kernel.org/networking/ip-sysctl.html)
  - [Kernel docs — sysctl / fs](https://docs.kernel.org/admin-guide/sysctl/fs.html) — file-max / aio
  - [Kernel docs — sysctl / kernel](https://docs.kernel.org/admin-guide/sysctl/kernel.html)
  - [Kernel docs — sysctl / net](https://docs.kernel.org/admin-guide/sysctl/net.html)
  - [Kernel docs — sysctl / vm](https://docs.kernel.org/admin-guide/sysctl/vm.html)
  - [Kernel Self-Protection Project — recommended settings](https://kspp.github.io/Recommended_Settings.html)
  - [kernel.org — kernel parameters](https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html)
  - [man7.org — inotify.7](https://man7.org/linux/man-pages/man7/inotify.7.html)
  - [queue.acm.org — detail.cfm](https://queue.acm.org/detail.cfm?id=3022184) — BBR + fq pacing
  - [Red Hat KB — strict reverse-path filtering](https://access.redhat.com/solutions/53031)
  - [rfc-editor.org — rfc1337](https://www.rfc-editor.org/rfc/rfc1337) — Arch Sysctl + most hardening guides invert this
  - [wiki.gentoo.org — Kernel Hardening with KSPP](https://wiki.gentoo.org/wiki/User:Pietinger/Tutorials/Kernel_Hardening_with_KSPP) — Gentoo (applies KSPP sysctls)
- `modules/boot/udev.nix`
  - [Arch Wiki — Improving performance (Changing I/O scheduler)](https://wiki.archlinux.org/title/Improving_performance#Changing_I/O_scheduler)
  - [Arch Wiki — Wake-on-LAN (systemd.link)](https://wiki.archlinux.org/title/Wake-on-LAN#systemd.link)
  - [freedesktop — systemd.link.html](https://www.freedesktop.org/software/systemd/man/latest/systemd.link.html)
  - [freedesktop — udev.html](https://www.freedesktop.org/software/systemd/man/latest/udev.html)
  - [Kernel docs — block / queue sysfs](https://docs.kernel.org/block/queue-sysfs.html)
  - [Kernel docs — block / switching sched](https://docs.kernel.org/block/switching-sched.html)
  - [kernel.org — sysfs devices power](https://www.kernel.org/doc/Documentation/ABI/testing/sysfs-devices-power)
  - [NixOS/nixpkgs/master/nixos/modules/hardware/iosched.nix](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/hardware/iosched.nix)
  - [NixOS/nixpkgs/master/nixos/modules/tasks/scsi-link-power-management.nix](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/tasks/scsi-link-power-management.nix)


## Security hardening

SSH, sysctl, and VPS baseline hardening.

- `modules/hardening/baseline.nix`
  - [freedesktop — coredump.conf.html](https://www.freedesktop.org/software/systemd/man/latest/coredump.conf.html)
  - [man7.org — limits.conf.5](https://man7.org/linux/man-pages/man5/limits.conf.5.html)
  - [NixOS Wiki — NixOS Hardening](https://wiki.nixos.org/wiki/NixOS_Hardening)
  - [NixOS/nixpkgs/master/nixos/modules/security/misc.nix](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/security/misc.nix)
- `modules/hardening/ssh.nix`
  - [infosec.mozilla.org — openssh](https://infosec.mozilla.org/guidelines/openssh)
  - [man.openbsd.org — sshd config](https://man.openbsd.org/sshd_config)
  - [stribika.github.io — secure secure shell](https://stribika.github.io/2015/01/04/secure-secure-shell.html)
- `modules/hardening/sysctl.nix`
  - [Arch Wiki — Security (Kernel hardening)](https://wiki.archlinux.org/title/Security#Kernel_hardening)
  - [Kernel docs — admin guide / sysrq](https://docs.kernel.org/admin-guide/sysrq.html)
  - [Kernel docs — LSM / Yama](https://docs.kernel.org/admin-guide/LSM/Yama.html)
  - [Kernel docs — networking / ip sysctl](https://docs.kernel.org/networking/ip-sysctl.html)
  - [Kernel docs — sysctl / fs](https://docs.kernel.org/admin-guide/sysctl/fs.html)
  - [Kernel docs — sysctl / kernel](https://docs.kernel.org/admin-guide/sysctl/kernel.html)
  - [Kernel Self-Protection Project — recommended settings](https://kspp.github.io/Recommended_Settings.html) — KSPP recommended kernel settings
  - [Red Hat KB — strict reverse-path filtering](https://access.redhat.com/solutions/53031)
  - [rfc-editor.org — rfc1337](https://www.rfc-editor.org/rfc/rfc1337)
  - [wiki.gentoo.org — Kernel Hardening with KSPP](https://wiki.gentoo.org/wiki/User:Pietinger/Tutorials/Kernel_Hardening_with_KSPP)


## AI & local models

Ollama, ComfyUI, Open WebUI, voice/TTS, Fish Audio, and ROCm on AMD.

- `modules/ai/comfyui.nix`
  - [Comfy-Org/ComfyUI — issue #2471](https://github.com/Comfy-Org/ComfyUI/issues/2471)
  - [Comfy-Org/ComfyUI/master/comfy/cli_args.py](https://github.com/Comfy-Org/ComfyUI/blob/master/comfy/cli_args.py)
  - [comfy.org docs — startup flags](https://docs.comfy.org/development/comfyui-server/startup-flags)
  - [developer.civitai.com — authentication](https://developer.civitai.com/site/guide/authentication)
  - [education.civitai.com — civitais guide to downloading via api](https://education.civitai.com/civitais-guide-to-downloading-via-api/)
  - [NixOS option search](https://search.nixos.org/options?query=virtualisation.oci-containers.containers)
  - [NixOS Wiki — Docker](https://wiki.nixos.org/wiki/Docker)
  - [rocm.docs.amd.com — environment variables](https://rocm.docs.amd.com/projects/ROCR-Runtime/en/latest/api-reference/environment_variables.html)
  - [rocm.docs.amd.com — find and immediate](https://rocm.docs.amd.com/projects/MIOpen/en/latest/how-to/find-and-immediate.html)
  - [rocm.docs.amd.com — finddb](https://rocm.docs.amd.com/projects/MIOpen/en/latest/conceptual/finddb.html)
  - [rocm.docs.amd.com — install pytorch](https://rocm.docs.amd.com/projects/radeon-ryzen/en/docs-7.1/docs/install/installryz/native_linux/install-pytorch.html)
- `modules/ai/default.nix`
  - [NixOS Wiki — Docker](https://wiki.nixos.org/wiki/Docker)
- `modules/ai/kiro-gateway.nix`
  - [jwadow/kiro-gateway](https://github.com/jwadow/kiro-gateway) — kiro-gateway upstream
  - [jwadow/kiro-gateway/main/.env.example](https://github.com/jwadow/kiro-gateway/blob/main/.env.example)
- `modules/ai/ollama.nix`
  - [amd/skills/main/staging/rocm-doctor/reference.md](https://github.com/amd/skills/blob/main/staging/rocm-doctor/reference.md)
  - [huggingface.co — ollama](https://huggingface.co/docs/hub/ollama)
  - [NixOS option search](https://search.nixos.org/options?query=services.ollama)
  - [NixOS Wiki — Ollama](https://wiki.nixos.org/wiki/Ollama)
  - [ollama.com docs — faq](https://docs.ollama.com/faq)
  - [ollama.com docs — gpu](https://docs.ollama.com/gpu) — Ollama: (6800/6900 yes; 6700 XT no)
  - [ollama.com docs — llms.txt](https://docs.ollama.com/llms.txt)
  - [ollama.com docs — modelfile](https://docs.ollama.com/modelfile)
  - [ollama.com docs — modelfile#template](https://docs.ollama.com/modelfile#template)
  - [ollama.com — library](https://ollama.com/library)
  - [ollama/ollama — issue #3547](https://github.com/ollama/ollama/issues/3547) — ROCm gfx1030 override for RX 6700 XT (gfx1031)
  - [ollama/ollama — issue #6003](https://github.com/ollama/ollama/issues/6003)
  - [rocm.docs.amd.com — environment variables](https://rocm.docs.amd.com/projects/ROCR-Runtime/en/latest/api-reference/environment_variables.html)
  - [rocm.docs.amd.com — system requirements](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/reference/system-requirements.html)
  - [ROCm/ROCm — issue #2720](https://github.com/ROCm/ROCm/issues/2720)
  - [ROCm/tensorflow-upstream — issue #2629](https://github.com/ROCm/tensorflow-upstream/issues/2629)
- `modules/ai/open-webui.nix`
  - [huggingface.co — Juggernaut XL V9 RDPhoto2 Lightning 4S](https://huggingface.co/imagepipeline/Juggernaut-XL-V9-RDPhoto2-Lightning_4S)
  - [localhost:11434](http://localhost:11434) — name is now OLLAMA_BASE_URL (default )
  - [NixOS option search](https://search.nixos.org/options?query=services.open-webui)
  - [open-webui/open-terminal](https://github.com/open-webui/open-terminal)
  - [openwebui.com docs — audio](https://docs.openwebui.com/troubleshooting/audio/)
  - [openwebui.com docs — configuration](https://docs.openwebui.com/features/open-terminal/advanced/configuration)
  - [openwebui.com docs — env configuration](https://docs.openwebui.com/getting-started/env-configuration)
  - [openwebui.com docs — env configuration#comfyui workflow](https://docs.openwebui.com/getting-started/env-configuration#comfyui_workflow)
  - [openwebui.com docs — env configuration#comfyui workflow nodes](https://docs.openwebui.com/getting-started/env-configuration#comfyui_workflow_nodes)
  - [openwebui.com docs — env configuration#ollama base url](https://docs.openwebui.com/getting-started/env-configuration#ollama_base_url)
  - [openwebui.com docs — env variables](https://docs.openwebui.com/features/chat-conversations/audio/speech-to-text/env-variables)
  - [openwebui.com docs — installation](https://docs.openwebui.com/features/open-terminal/setup/installation/) — Open WebUI open-terminal setup
- `modules/ai/voice.nix`
  - [api.fish.audio — tts](https://api.fish.audio/v1/tts) — Fish's native API is POST (model in header), not /v1/audio/speech
  - [devnen/Chatterbox-TTS-Server](https://github.com/devnen/Chatterbox-TTS-Server)
  - [devnen/Chatterbox-TTS-Server/main/docker-compose-rocm.yml](https://github.com/devnen/Chatterbox-TTS-Server/blob/main/docker-compose-rocm.yml)
  - [docker.com docs — bridge](https://docs.docker.com/engine/network/drivers/bridge/)
  - [fish.audio docs — llms.txt](https://docs.fish.audio/llms.txt)
  - [fish.audio docs — quickstart](https://docs.fish.audio/developer-guide/getting-started/quickstart) — FISH_API_KEY. Official env name
  - [fish.audio docs — text to speech](https://docs.fish.audio/api-reference/endpoint/openapi-v1/text-to-speech)
  - [Local endpoint (127.0.0.1:18083)](http://127.0.0.1:18083) — 0.1B, 48 kHz stereo, CPU. Official demo: python app.py → (Gradio)
  - [NixOS option search](https://search.nixos.org/options?query=virtualisation.oci-containers.containers)
  - [NixOS Wiki — Docker](https://wiki.nixos.org/wiki/Docker)
  - [OpenMOSS/MOSS-TTS-Nano](https://github.com/OpenMOSS/MOSS-TTS-Nano)
  - [openwebui.com docs — env variables](https://docs.openwebui.com/features/chat-conversations/audio/speech-to-text/env-variables)
  - [openwebui.com docs — Kokoro FastAPI integration](https://docs.openwebui.com/features/chat-conversations/audio/text-to-speech/Kokoro-FastAPI-integration/)
  - [remsky/Kokoro-FastAPI](https://github.com/remsky/Kokoro-FastAPI)
  - [resemble-ai/chatterbox](https://github.com/resemble-ai/chatterbox)
  - [speaches-ai/speaches](https://github.com/speaches-ai/speaches/releases/tag/v0.9.0-rc.3)
  - [speaches.ai](https://speaches.ai/) — installation/ configuration/
  - [speaches.ai — configuration](https://speaches.ai/configuration/) — installation/ configuration/
  - [speaches.ai — installation](https://speaches.ai/installation/) — installation/ configuration/
  - [speaches.ai — speech to text](https://speaches.ai/usage/speech-to-text/)
  - [SYSTRAN/faster-whisper](https://github.com/SYSTRAN/faster-whisper)


## Audio & PipeWire

PipeWire, WirePlumber, and pro-audio latency.

- `modules/audio/default.nix`
  - [Arch Wiki — Professional audio](https://wiki.archlinux.org/title/Professional_audio)
  - [man7.org — limits.conf.5](https://man7.org/linux/man-pages/man5/limits.conf.5.html)
  - [NixOS Wiki — PipeWire](https://wiki.nixos.org/wiki/PipeWire)
  - [pipewire.org docs — page module rt](https://docs.pipewire.org/page_module_rt.html)
- `modules/audio/pipewire.nix`
  - [Arch Wiki — PipeWire (Changing the default sample rate)](https://wiki.archlinux.org/title/PipeWire#Changing_the_default_sample_rate)
  - [pipewire.org docs — page man pipewire conf 5](https://docs.pipewire.org/page_man_pipewire_conf_5.html)
- `modules/audio/wireplumber.nix`
  - [Arch Wiki — PipeWire (Noticeable audio delay or audible pop/crack when starting playback)](https://wiki.archlinux.org/title/PipeWire#Noticeable_audio_delay_or_audible_pop/crack_when_starting_playback)
  - [Arch Wiki — WirePlumber](https://wiki.archlinux.org/title/WirePlumber)
  - [freedesktop — alsa.html](https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration/alsa.html)
  - [freedesktop — settings.html](https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration/settings.html) — 0.8 = 80% (linear)


## Desktop

Theme, fonts, XDG, keyring, and session defaults.

- `modules/desktop/fonts.nix`
  - [Arch Wiki — Font configuration](https://wiki.archlinux.org/title/Font_configuration)
  - [freedesktop — fontconfig-user.html](https://fontconfig.pages.freedesktop.org/fontconfig/fontconfig-user.html)
  - [gitlab.com — inter nerdfont](https://gitlab.com/mid_os/inter-nerdfont)
  - [nerdfonts.com](https://www.nerdfonts.com/)
  - [NixOS Wiki — Fonts](https://wiki.nixos.org/wiki/Fonts) — with fontconfig
  - [NixOS Wiki — Fonts](https://wiki.nixos.org/wiki/Fonts#Noto_Color_Emoji_doesn) — 't_render_on_Firefox
  - [rsms.me — inter](https://rsms.me/inter/)
- `modules/desktop/keyring.nix`
  - [NixOS Wiki — GNOME](https://wiki.nixos.org/wiki/GNOME)
- `modules/desktop/security.nix`
  - [man7.org — limits.conf.5](https://man7.org/linux/man-pages/man5/limits.conf.5.html)
- `modules/desktop/xdg.nix`
  - [freedesktop — latest](https://specifications.freedesktop.org/basedir-spec/latest/)
  - [mise.jdx.dev — settings#all compile](https://mise.jdx.dev/configuration/settings.html#all_compile)
  - [NixOS Wiki — XDG Base Directory](https://wiki.nixos.org/wiki/XDG_Base_Directory)


## Sway & Wayland

Sway, Waybar, portals, clipboard, and window rules.

- `modules/desktop/sway/autostart.nix`
  - [ammernico/autotiling-rs](https://github.com/ammernico/autotiling-rs) — not exec_always (two copies fight)
  - [Arch Wiki — Sway (Mouse not working in WINE applications)](https://wiki.archlinux.org/title/Sway#Mouse_not_working_in_WINE_applications)
  - [Linus789/wl-clip-persist](https://github.com/Linus789/wl-clip-persist)
  - [man.archlinux.org — swayidle.1](https://man.archlinux.org/man/swayidle.1)
  - [sentriz/cliphist](https://github.com/sentriz/cliphist)
- `modules/desktop/sway/config.nix`
  - [Arch Wiki — Sway](https://wiki.archlinux.org/title/Sway)
  - [man.archlinux.org — sway output.5](https://man.archlinux.org/man/sway-output.5)
  - [man.archlinux.org — sway.5](https://man.archlinux.org/man/sway.5)
  - [swaywm/sway/master/config.in](https://github.com/swaywm/sway/blob/master/config.in)
- `modules/desktop/sway/default.nix`
  - [emersion/xdg-desktop-portal-wlr — issue #395](https://github.com/emersion/xdg-desktop-portal-wlr/issues/395)
  - [emersion/xdg-desktop-portal-wlr/master/contrib/wlroots-portals.conf](https://github.com/emersion/xdg-desktop-portal-wlr/blob/master/contrib/wlroots-portals.conf)
  - [NixOS Wiki — Sway](https://wiki.nixos.org/wiki/Sway)
  - [swaywm/sway wiki](https://github.com/swaywm/sway/wiki)
  - [swaywm/sway wiki](https://github.com/swaywm/sway/wiki/Running-programs-natively-under-wayland)
  - [swaywm/sway — issue #8498](https://github.com/swaywm/sway/issues/8498)
- `modules/desktop/sway/swaylock.nix`
  - [jirutka/swaylock-effects](https://github.com/jirutka/swaylock-effects)
- `modules/desktop/sway/swaync.nix`
  - [ErikReider/SwayNotificationCenter](https://github.com/ErikReider/SwayNotificationCenter) — SwayNotificationCenter
- `modules/desktop/sway/swayr.nix`
  - [git.sr.ht — swayr](https://git.sr.ht/~tsdh/swayr)
- `modules/desktop/sway/waybar.nix`
  - [Alexays/Waybar wiki](https://github.com/Alexays/Waybar/wiki)
- `modules/desktop/sway/windows.nix`
  - [runelite/runelite — issue #19076](https://github.com/runelite/runelite/issues/19076)


## Development

Editor and dev tooling.

- `modules/dev/cursor.nix`
  - [cursor.com — docs](https://www.cursor.com/docs)


## Gaming

Steam, Proton, GameMode, emulators, and compatibility lists.

- `modules/gaming/crankshaft.nix`
  - [KraXen72/crankshaft](https://github.com/KraXen72/crankshaft)
- `modules/gaming/default.nix`
  - [Arch Wiki — Gaming](https://wiki.archlinux.org/title/Gaming)
  - [fufexan/nix-gaming](https://github.com/fufexan/nix-gaming) — nix-gaming (optional titles + wine-tkg)
  - [NixOS Wiki — Steam](https://wiki.nixos.org/wiki/Steam)
  - [pipewire.org docs — page man libpipewire module rt 7](https://docs.pipewire.org/page_man_libpipewire-module-rt_7.html)
- `modules/gaming/emulators.nix`
  - [dolphin-emu.org](https://dolphin-emu.org/)
  - [pcsx2.net](https://pcsx2.net/)
  - [retroarch.com](https://www.retroarch.com/)
  - [rpcs3.net](https://rpcs3.net/)
- `modules/gaming/env.nix`
  - [doitsujin/dxvk wiki](https://github.com/doitsujin/dxvk/wiki/Configuration)
  - [kcat/openal-soft/master/alsoftrc.sample](https://github.com/kcat/openal-soft/blob/master/alsoftrc.sample)
  - [phoronix.com — RADV GPL Mesa 23.1 Default](https://www.phoronix.com/news/RADV-GPL-Mesa-23.1-Default)
- `modules/gaming/epic.nix`
  - [derrod/legendary](https://github.com/derrod/legendary)
  - [fufexan/nix-gaming](https://github.com/fufexan/nix-gaming)
- `modules/gaming/games.nix`
  - [fufexan/nix-gaming](https://github.com/fufexan/nix-gaming)
- `modules/gaming/kernel.nix`
  - [Arch Wiki — Gaming](https://wiki.archlinux.org/title/Gaming)
  - [fufexan/nix-gaming](https://github.com/fufexan/nix-gaming)
  - [Kernel docs — driver api / ntsync](https://docs.kernel.org/driver-api/ntsync.html)
- `modules/gaming/mangohud.nix`
  - [flightlessmango/MangoHud](https://github.com/flightlessmango/MangoHud)
  - [Kernel docs — sysctl / kernel](https://docs.kernel.org/admin-guide/sysctl/kernel.html#perf-event-paranoid)
- `modules/gaming/prismlauncher.nix`
  - [prismlauncher.org](https://prismlauncher.org/)
- `modules/gaming/runelite.nix`
  - [runelite/runelite](https://github.com/runelite/runelite) — RuneLite (OSRS)
- `modules/gaming/steam.nix`
  - [areweanticheatyet.com](https://areweanticheatyet.com/) — Compat: Anti-cheat
  - [NixOS Wiki — Steam](https://wiki.nixos.org/wiki/Steam)
  - [protondb.com](https://www.protondb.com/) — Compat: Anti-cheat
  - [Supreeeme/extest](https://github.com/Supreeeme/extest)
  - [ValveSoftware/Proton](https://github.com/ValveSoftware/Proton)
- `modules/gaming/tools.nix`
  - [FeralInteractive/gamemode](https://github.com/FeralInteractive/gamemode)
  - [nowrep/obs-vkcapture](https://github.com/nowrep/obs-vkcapture)
  - [ollama/ollama/main/docs/api.md](https://github.com/ollama/ollama/blob/main/docs/api.md) — keep_alive=0
  - [sonic2kk/steamtinkerlaunch](https://github.com/sonic2kk/steamtinkerlaunch) — SteamTinkerLaunch
  - [ValveSoftware/gamescope](https://github.com/ValveSoftware/gamescope)
- `modules/gaming/wine.nix`
  - [derrod/legendary](https://github.com/derrod/legendary)
  - [NixOS/nixpkgs — issue #513245](https://github.com/NixOS/nixpkgs/issues/513245) — (closed; skip-test PRs exist)
  - [Open-Wine-Components/umu-launcher](https://github.com/Open-Wine-Components/umu-launcher)


## Music production

DAWs, plugins, yabridge, and FL Studio on Linux.

- `modules/music/daws.nix`
  - [ardour.org](https://ardour.org/) — Ardour 9 — — LV2/VST2/VST3/LADSPA, reads env vars
  - [bitwig.com](https://www.bitwig.com/) — Bitwig 6 — — VST2/VST3/CLAP, no LV2
  - [linuxdj.com — bitwig studio 6 on linux performance and pipewire workflow 2026](https://www.linuxdj.com/notes/bitwig-studio-6-on-linux-performance-and-pipewire-workflow-2026/)
  - [lmms.io](https://lmms.io/) — LMMS 1.2.2 — — VST2 + LADSPA only (1.3 still not in nixpkgs)
  - [reaper.fm](https://www.reaper.fm/) — REAPER 7 — — VST2/VST3/CLAP/LV2/JSFX
  - [sws-extension.org](https://www.sws-extension.org/)
  - [zrythm.org](https://www.zrythm.org/) — Zrythm 1.0 — — LV2/VST2/VST3/CLAP/LADSPA/DSSI
- `modules/music/default.nix`
  - [Arch Wiki — Professional audio](https://wiki.archlinux.org/title/Professional_audio)
  - [Arch Wiki — Professional audio (System configuration)](https://wiki.archlinux.org/title/Professional_audio#System_configuration)
  - [cleveraudio.org](https://cleveraudio.org/)
  - [freedesktop — qpwgraph](https://gitlab.freedesktop.org/rncbc/qpwgraph)
  - [lv2plug.in — filesystem hierarchy standard](https://lv2plug.in/pages/filesystem-hierarchy-standard.html)
  - [musnix/musnix](https://github.com/musnix/musnix) — musnix udev/sysctl patterns
  - [NixOS Wiki — Audio production](https://wiki.nixos.org/wiki/Audio_production)
  - [NixOS Wiki — PipeWire](https://wiki.nixos.org/wiki/PipeWire#JACK)
  - [pipewire.org docs — page man pipewire conf 5](https://docs.pipewire.org/page_man_pipewire_conf_5.html)
- `modules/music/flstudio.nix`
  - [appdb.winehq.org — objectManager.php](https://appdb.winehq.org/objectManager.php?sClass=application&iId=2317) — WineHQ AppDB
  - [begin-theadventure/fl-studio-integrator-linux](https://github.com/begin-theadventure/fl-studio-integrator-linux)
  - [forum.image-line.com — viewtopic.php](https://forum.image-line.com/viewtopic.php?t=198535)
  - [forum.image-line.com — viewtopic.php](https://forum.image-line.com/viewtopic.php?t=259129)
  - [freedesktop — 0bc3d1444a98d7e868563a03bf555f28f14e7f2d](https://gitlab.freedesktop.org/pipewire/pipewire/-/commit/0bc3d1444a98d7e868563a03bf555f28f14e7f2d)
  - [freedesktop — category-registry.html](https://specifications.freedesktop.org/menu-spec/latest/category-registry.html)
  - [freedesktop — latest](https://specifications.freedesktop.org/shared-mime-info-spec/latest/)
  - [freedesktop — latest](https://specifications.freedesktop.org/mime-apps-spec/latest/)
  - [M0n7y5/pipeasio](https://github.com/M0n7y5/pipeasio)
  - [support.image-line.com — knowledgebase](https://support.image-line.com/action/knowledgebase?ans=140)
  - [wineasio/wineasio](https://github.com/wineasio/wineasio)
- `modules/music/plugins.nix`
  - [airwindows.com](https://www.airwindows.com/)
  - [calf-studio-gear.org](https://calf-studio-gear.org/) — filters, verb, delay
  - [cardinal.kx.studio](https://cardinal.kx.studio/) — VCV Rack as plugin
  - [Chowdhury-DSP/ChowTapeModel](https://github.com/Chowdhury-DSP/ChowTapeModel)
  - [cleveraudio.org](https://cleveraudio.org/)
  - [DISTRHO/DISTRHO-Ports](https://github.com/DISTRHO/DISTRHO-Ports) — Obxd, TAL-NoiseMaker, Vex
  - [geonkick.org](https://geonkick.org/) — percussion synth
  - [hydrogen-music.org](http://hydrogen-music.org/) — pattern drum machine
  - [linuxdaw.org](https://linuxdaw.org/)
  - [lsp-plug.in](https://lsp-plug.in/) — EQ/comp/limiter
  - [lv2plug.in](https://lv2plug.in/)
  - [michaelwillis/dragonfly-reverb](https://github.com/michaelwillis/dragonfly-reverb) — hall/room/plate
  - [NixOS Wiki — Audio production](https://wiki.nixos.org/wiki/Audio_production)
  - [sfz.tools — sfizz](https://sfz.tools/sfizz/)
  - [surge-synthesizer.github.io](https://surge-synthesizer.github.io/) — hybrid; LV2/VST3/CLAP
  - [vital.audio](https://vital.audio/) — wavetable (unfree)
  - [x42-plugins.com](https://x42-plugins.com/) — meters, tuner
  - [zamaudio.com](https://www.zamaudio.com/) — dynamics / tube
  - [zynaddsubfx.sourceforge.io](https://zynaddsubfx.sourceforge.io/) — additive / pads
- `modules/music/tools.nix`
  - [kx.studio — Applications:Carla](https://kx.studio/Applications:Carla)
  - [tenacityaudio.org](https://tenacityaudio.org/)
- `modules/music/yabridge.nix`
  - [robbert-vdh/yabridge](https://github.com/robbert-vdh/yabridge)
  - [yabridge.org](https://yabridge.org/)


## Programs

Firefox policies, extensions, and desktop apps.

- `modules/programs/firefox.nix`
  - [addons.mozilla.org — llmfeeder](https://addons.mozilla.org/firefox/addon/llmfeeder/) — guid from AMO API
  - [arkenfox/user.js](https://github.com/arkenfox/user.js) — Not an arkenfox port. (v144)
  - [firefox-admin-docs.mozilla.org](https://firefox-admin-docs.mozilla.org/) — Policies: (legacy index: )
  - [firefox-admin-docs.mozilla.org — dnsoverhttps](https://firefox-admin-docs.mozilla.org/reference/policies/dnsoverhttps/)
  - [firefox-admin-docs.mozilla.org — enabletrackingprotection](https://firefox-admin-docs.mozilla.org/reference/policies/enabletrackingprotection/)
  - [firefox-admin-docs.mozilla.org — firefoxhome](https://firefox-admin-docs.mozilla.org/reference/policies/firefoxhome/)
  - [firefox-admin-docs.mozilla.org — firefoxsuggest](https://firefox-admin-docs.mozilla.org/reference/policies/firefoxsuggest/)
  - [firefox-admin-docs.mozilla.org — generativeai](https://firefox-admin-docs.mozilla.org/reference/policies/generativeai/)
  - [firefox-admin-docs.mozilla.org — httpsonlymode](https://firefox-admin-docs.mozilla.org/reference/policies/httpsonlymode/)
  - [firefox-admin-docs.mozilla.org — networkprediction](https://firefox-admin-docs.mozilla.org/reference/policies/networkprediction/)
  - [mozilla.github.io — policy templates](https://mozilla.github.io/policy-templates/) — Policies: (legacy index: )
  - [NixOS option search](https://search.nixos.org/options?query=programs.firefox.preferencesStatus)
  - [NixOS Wiki — Firefox](https://wiki.nixos.org/wiki/Firefox)
  - [support.mozilla.org — 1270059](https://support.mozilla.org/en-US/questions/1270059)


## Services

Docker, libvirt, qBittorrent, copyparty, and daemons.

- `modules/services/docker.nix`
  - [docker.com docs — dockerd#daemon-configuration-file](https://docs.docker.com/reference/cli/dockerd/#daemon-configuration-file)
  - [docker.com docs — live restore](https://docs.docker.com/engine/daemon/live-restore/)
  - [docker.com docs — prune](https://docs.docker.com/reference/cli/docker/system/prune/)
  - [NixOS Wiki — Docker](https://wiki.nixos.org/wiki/Docker) — (NixOS default is podman)
- `modules/services/libvirt.nix`
  - [libvirt.org — nss](https://libvirt.org/nss.html)
  - [NixOS Wiki — Libvirt](https://wiki.nixos.org/wiki/Libvirt)
- `modules/services/polkit.nix`
  - [freedesktop — polkit.8.html](https://www.freedesktop.org/software/polkit/docs/latest/polkit.8.html#polkit-rules)
  - [NixOS Wiki — Polkit](https://wiki.nixos.org/wiki/Polkit)
  - [storaged.org — udisks polkit actions](https://storaged.org/doc/udisks2-api/latest/udisks-polkit-actions.html)
- `modules/services/qbittorrent.nix`
  - [libtorrent.org — reference Settings](https://www.libtorrent.org/reference-Settings.html) — libtorrent 2.1.0
  - [NixOS/nixpkgs/master/nixos/modules/services/torrent/qbittorrent.nix](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/torrent/qbittorrent.nix)
  - [qbittorrent/qBittorrent wiki](https://github.com/qbittorrent/qBittorrent/wiki/Explanation-of-Options-in-qBittorrent)
- `modules/services/qui.nix`
  - [Local endpoint (127.0.0.1:7476)](http://127.0.0.1:7476)
  - [Local endpoint (127.0.0.1:8080)](http://127.0.0.1:8080) — at (same user as config.my.username)
- `modules/services/vagrant.nix`
  - [developer.hashicorp.com — default](https://developer.hashicorp.com/vagrant/docs/providers/default)
  - [libvirt.org — formatnetwork](https://libvirt.org/formatnetwork.html)
  - [NixOS Wiki — Vagrant](https://wiki.nixos.org/wiki/Vagrant)
  - [vagrant-libvirt.github.io — vagrant libvirt](https://vagrant-libvirt.github.io/vagrant-libvirt/)


## Wine

Wine prefixes, winetricks, and Windows audio.

- `modules/wine/default.nix`
  - [Arch Wiki — Font configuration (Xft settings)](https://wiki.archlinux.org/title/Font_configuration#Xft_settings)
  - [Frogging-Family/wine-tkg-git](https://github.com/Frogging-Family/wine-tkg-git)
  - [fufexan/nix-gaming/master/modules/wine.nix](https://github.com/fufexan/nix-gaming/blob/master/modules/wine.nix)
  - [wiki.winehq.org — Wine User's Guide](https://wiki.winehq.org/Wine_User%27s_Guide)
  - [Winetricks/winetricks](https://github.com/Winetricks/winetricks)


## CLI wrappers

Upstream docs for themed terminal tools.

- `modules/wrappers/btop.nix`
  - [aristocratos/btop](https://github.com/aristocratos/btop) — config / --themes-dir
- `modules/wrappers/profanity.nix`
  - [profanity-im.github.io — files](https://profanity-im.github.io/guide/latest/files.html)

---

*278 links · 13 sections*
