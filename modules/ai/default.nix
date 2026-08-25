# Desktop AI stack — all inference, agents, and AI tooling.
{
  imports = [
    ./ollama.nix
    ./comfyui.nix
    ./open-webui.nix
    ./voice.nix
    ./kiro-gateway.nix
    # hermes-agent / sillytavern retired → archive/ (gitignored)
  ];

  # Docker backend for voice containers + open-terminal.
  # https://wiki.nixos.org/wiki/Docker
  virtualisation.oci-containers.backend = "docker";
}
