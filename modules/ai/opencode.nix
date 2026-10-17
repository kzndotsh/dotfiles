# opencode — declarative ~/.config/opencode/opencode.jsonc via tmpfiles store symlink.
# Kiro API key via {file:…} (kiro-gateway writes ~/.secrets/kiro-proxy-api-key from ai.env).
# Never stored in the Nix store.
{ pkgs, config, ... }:
let
  inherit (config.my) home username secretsDir;

  opencodeConfig = pkgs.writeText "opencode.jsonc" ''
    {
      "$schema": "https://opencode.ai/config.json",
      "lsp": true,
      "provider": {
        "kiro": {
          "npm": "@ai-sdk/openai-compatible",
          "name": "Kiro Gateway",
          "options": {
            "baseURL": "http://127.0.0.1:9000/v1",
            "apiKey": "{file:${secretsDir}/kiro-proxy-api-key}"
          },
          "models": {
            "claude-sonnet-4-6": {
              "name": "Claude Sonnet 4.6",
              "limit": { "context": 1000000, "output": 8192 },
              "attachment": true,
              "reasoning": true,
              "tool_call": true,
              "temperature": true,
              "modalities": { "input": ["text", "image"] }
            }
          }
        }
      }
    }
  '';
in
{
  systemd.tmpfiles.rules = [
    "d ${home}/.config/opencode 0755 ${username} users -"
    "L+ ${home}/.config/opencode/opencode.jsonc - - - - ${opencodeConfig}"
  ];
}
