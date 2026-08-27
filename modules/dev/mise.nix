# Global mise tooling — config.toml (settings) + conf.d fragments + home-prefix dirs (desktop only).
{ pkgs, config, ... }:
let
  inherit (config.my) home username;

  npmrc = pkgs.writeText "npmrc" ''
    prefix=''${HOME}/.local/share/npm
  '';

  pipConf = pkgs.writeText "pip.conf" ''
    [global]
    user = true
  '';

  # Shared settings — tool pins live in conf.d/*.toml (mise merges them unconditionally).
  miseConfig = pkgs.writeText "mise-config.toml" ''
    [settings]
    idiomatic_version_file_enable_tools = ["node", "pnpm", "python"]
    python.uv_venv_auto = "create|source"
  '';

  nodejsFragment = pkgs.writeText "nodejs.toml" ''
    [tools]
    node = "24.20.0"
    pnpm = "10.33.0"
    bun = "1.3.13"
  '';

  pythonFragment = pkgs.writeText "python.toml" ''
    [tools]
    python = "3.12.14"
    uv = "0.12.6"

    [env]
    # Keep uv on mise-managed python, not nixpkgs/system interpreters.
    UV_PYTHON = { value = "{{ tools.python.path }}", tools = true }
  '';

  # Importable libs for one-shot scripts / agents — CLIs (ipython, httpie) are nixpkgs in shell/.
  scriptingRequirements = pkgs.writeText "mise-python-scripting.txt" ''
    requests==2.34.2
    httpx[http2,socks]==0.28.1
    aiohttp==3.14.3
    websockets==17.1
    cryptography==50.0.1
    PyJWT==2.13.0
    python-dotenv==1.2.3
    PyYAML==6.0.3
    orjson==3.12.0
    beautifulsoup4==4.15.0
    lxml==6.1.2
    rich==15.0.0
    typer==0.27.1
    tqdm==4.70.0
    tenacity==9.1.4
    python-dateutil==2.9.0.post0
    paramiko==5.0.0
    dnspython==2.8.0
    Pillow==12.3.0
    openai==3.5.0
    anthropic==1.1.0
    loguru==0.7.3
    psutil==7.2.2
    jinja2==3.1.6
    tomli==2.4.1
    tomli-w==1.2.0
    jsonschema==4.26.0
    selectolax==0.4.11
    pathspec==1.1.1
    mcp==2.1.1
    httpx-sse==0.4.3
    tiktoken==0.14.0
    pypdf==6.16.2
    markdown-it-py==4.2.0
  '';

  miseGlobalToolsScript = pkgs.writeShellScript "mise-global-tools" ''
    set -euo pipefail
    export HOME="${home}"
    export PATH="/run/current-system/sw/bin:/run/current-system/sw/sbin:$PATH"
    export MISE_ALL_COMPILE=false
    export MISE_NODE_COMPILE=false
    export MISE_PYTHON_COMPILE=false
    ${pkgs.mise}/bin/mise install
    PYTHON="$(${pkgs.mise}/bin/mise which python)"
    UV="$(${pkgs.mise}/bin/mise which uv)"
    "$UV" pip install --python "$PYTHON" -r ${scriptingRequirements}
  '';
in
{
  systemd.tmpfiles.rules = [
    "d ${home}/.config/npm 0755 ${username} users -"
    "L+ ${home}/.config/npm/npmrc - - - - ${npmrc}"
    "d ${home}/.config/pip 0755 ${username} users -"
    "L+ ${home}/.config/pip/pip.conf - - - - ${pipConf}"
    "d ${home}/.config/mise 0755 ${username} users -"
    "d ${home}/.config/mise/conf.d 0755 ${username} users -"
    "L+ ${home}/.config/mise/config.toml - - - - ${miseConfig}"
    "L+ ${home}/.config/mise/conf.d/nodejs.toml - - - - ${nodejsFragment}"
    "L+ ${home}/.config/mise/conf.d/python.toml - - - - ${pythonFragment}"
    "d ${home}/.local/share/npm 0755 ${username} users -"
    "d ${home}/.local/share/pnpm 0755 ${username} users -"
    "d ${home}/.local/share/bun 0755 ${username} users -"
    "d ${home}/.local/share/python 0755 ${username} users -"
  ];

  # Idempotent — fast when tools are already installed; avoids network during nixos-rebuild.
  systemd.user.services.mise-global-tools = {
    description = "Install mise global dev tools";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Environment = [
        "HOME=${home}"
        "PATH=/run/current-system/sw/bin:/run/current-system/sw/sbin"
        "MISE_ALL_COMPILE=false"
        "MISE_NODE_COMPILE=false"
        "MISE_PYTHON_COMPILE=false"
      ];
      ExecStart = miseGlobalToolsScript;
    };
  };
}
