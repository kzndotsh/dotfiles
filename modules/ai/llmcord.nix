# llmcord — Discord LLM frontend (https://github.com/jakobdylanc/llmcord).
# Talks to the local kiro-gateway (:9000, OpenAI-compatible /v1) — see kiro-gateway.nix.
#
# Secrets (never in the store): ~/.secrets/llmcord.env
#   DISCORD_BOT_TOKEN=…   DISCORD_CLIENT_ID=…
# The kiro key comes from ~/.secrets/ai.env (PROXY_API_KEY / KIRO_GATEWAY_API_KEY), same file kiro-gateway reads.
#
# config.yaml is generated from Nix (JSON ⊂ YAML) and symlinked into the state dir,
# because llmcord reads ./config.yaml from its cwd. Edit options, not the file.
{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.ai.llmcord;
  inherit (config.my) username secretsDir;

  python = pkgs.python3.withPackages (ps: with ps; [
    discordpy
    httpx
    openai
    python-dotenv
    pyyaml
  ]);

  settings = {
    bot_token_env = "DISCORD_BOT_TOKEN";
    client_id_env = "DISCORD_CLIENT_ID";
    status_message = cfg.statusMessage;
    inherit (cfg) max_text max_images max_messages;
    use_plain_responses = false;
    allow_dms = cfg.allowDms;
    permissions = {
      users = {
        admin_ids = cfg.adminIds;
        allowed_ids = cfg.allowedUserIds;
        blocked_ids = [ ];
      };
      roles = { allowed_ids = [ ]; blocked_ids = [ ]; };
      channels = { allowed_ids = cfg.allowedChannelIds; blocked_ids = [ ]; };
    };
    providers.kiro = {
      base_url = "http://127.0.0.1:9000/v1";
      api_key_env = "PROXY_API_KEY";
    };
    # First model is the startup default; `/model` switches between them.
    models = lib.genAttrs (map (m: "kiro/${m}") cfg.models) (_: null);
    system_prompt = cfg.systemPrompt;
  };

  # ai.env may only define the KIRO_GATEWAY_API_KEY alias; kiro-gateway mirrors the key to a file.
  start = pkgs.writeShellScript "llmcord-start" ''
    PROXY_API_KEY="''${PROXY_API_KEY:-''${KIRO_GATEWAY_API_KEY:-$(cat ${secretsDir}/kiro-proxy-api-key 2>/dev/null)}}"
    export PROXY_API_KEY
    exec ${python}/bin/python ${inputs.llmcord}/llmcord.py
  '';

  configFile = pkgs.writeText "llmcord-config.yaml" (builtins.toJSON settings);
in
{
  options.ai.llmcord = {
    enable = lib.mkEnableOption "llmcord Discord bot backed by kiro-gateway";

    models = lib.mkOption {
      type = lib.types.nonEmptyListOf lib.types.str;
      default = [ "claude-haiku-4-5" ];
      description = "kiro-gateway model ids (see `curl :9000/v1/models`); first is the default";
    };

    statusMessage = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Bot profile status (max 128 chars)";
    };

    systemPrompt = lib.mkOption {
      type = lib.types.str;
      default = ''
        You are a helpful Discord chatbot. Be concise.

        Today's date is {date}. The current time is {time}.

        User messages are prefixed with their Discord ID as <@ID>. Use this format to mention users.

        # Formatting rules
        Your replies render in Discord, which supports only a limited Markdown subset. Use ONLY the syntax below. Anything else shows up as literal characters.

        Allowed:
        - *italic* or _italic_, **bold**, ***bold italic***, __underline__, ~~strikethrough~~
        - Headers: `# `, `## `, `### ` at the start of a line, with a space after the hashes. Three levels max. Use sparingly, only for long structured answers.
        - Subtext: `-# ` at the start of a line for small, dim text.
        - Bulleted lists: `- ` or `* ` at the start of a line. Indent nested items with exactly 2 spaces. Numbered lists: `1. `.
        - Block quotes: `> ` for one line, `>>> ` before the first line to quote everything after it.
        - Inline code with single backticks. Code blocks with triple backticks, always with a language tag (```python, ```nix, ```bash, ```json), and the closing ``` on its own line.
        - Masked links: [text](https://example.com). Bare URLs also work.
        - Spoilers: ||text||. They do not work inside code blocks.
        - Mentions: <@ID> for users only when you know the ID. Never invent IDs. Never use @everyone or @here.
        - Timestamps: <t:UNIX:f> (also :t :T :d :D :F :R). Only use them when you can compute a correct Unix time.
        - Backslash escapes (\*, \_, \`, \~) when you need a literal formatting character.

        NOT supported. Never use:
        - Tables (pipes and dashes). Use a bulleted list or a code block instead.
        - Horizontal rules (---, ***, ___).
        - Images or embedded images: ![alt](url).
        - HTML tags, LaTeX or math syntax ($...$, \(...\)). Write math in plain text or in a code block.
        - Headers deeper than ###. Do not use #### or lower.
        - Footnotes, task lists ([ ] / [x]), definition lists, or emoji shortcodes like :smile: unless the user is clearly using them.
        - Nested or mixed formatting that gets noisy. Do not stack bold, italic, underline and headers on the same text.

        Style:
        - Keep replies short. One Discord message is 2000 characters or fewer, and long replies get split into several messages. Prefer a tight answer, and offer more detail if the user wants it.
        - Do not wrap the whole reply in a code block.
        - No filler openers ("Sure!", "Great question!") and no closing offers to help further.
        - Use code blocks for code, commands, config and logs, and inline code for names, paths and flags.
      '';
    };

    adminIds = lib.mkOption { type = lib.types.listOf lib.types.int; default = [ ]; description = "Discord user ids allowed to run /model"; };
    allowedUserIds = lib.mkOption { type = lib.types.listOf lib.types.int; default = [ ]; description = "Empty = everyone"; };
    allowedChannelIds = lib.mkOption { type = lib.types.listOf lib.types.int; default = [ ]; description = "Empty = all channels"; };
    allowDms = lib.mkOption { type = lib.types.bool; default = true; };
    max_text = lib.mkOption { type = lib.types.int; default = 100000; };
    max_images = lib.mkOption { type = lib.types.int; default = 5; };
    max_messages = lib.mkOption { type = lib.types.int; default = 25; };
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      tmpfiles.rules = [
        "d /var/lib/llmcord 0750 ${username} users -"
        "L+ /var/lib/llmcord/config.yaml - - - - ${configFile}"
      ];

      services.llmcord = {
        description = "llmcord — Discord LLM bot (kiro-gateway backend)";
        after = [ "network-online.target" "kiro-gateway.service" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        restartTriggers = [ configFile inputs.llmcord ];
        serviceConfig = {
          User = username;
          Group = "users";
          WorkingDirectory = "/var/lib/llmcord";
          EnvironmentFile = [ "-${secretsDir}/ai.env" "-${secretsDir}/llmcord.env" ];
          ExecStart = start;
          Restart = "on-failure";
          RestartSec = 10;
        };
      };
    };
  };
}
