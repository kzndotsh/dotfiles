# Local AI stack: LLM inference, image gen, chat UI, voice, and the Kiro proxy.
{
  imports = [
    ./ollama.nix
    ./comfyui.nix
    ./open-webui.nix
    ./voice.nix
    ./w-okada.nix
    ./kiro-gateway.nix
    # hermes-agent and sillytavern retired — see archive/ (gitignored)
  ];

  # Voice containers and open-terminal expect Docker, not podman.
  virtualisation.oci-containers.backend = "docker";
}
