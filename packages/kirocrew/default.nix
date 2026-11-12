# Kiro Crew gateway. Pinned wheel — not in nixpkgs, and the source build needs Node.
# Python 3.13 matches upstream's 3.12–3.13 range. Nix sqlite has FTS5, so the
# Linux-only pysqlite3-binary wheel is dropped. PPTX maker calls pkgs.uv.
{
  lib,
  stdenv,
  fetchurl,
  callPackage,
  python313,
  autoPatchelfHook,
  git,
  runCommand,
  makeWrapper,
  cacert,
  kiro-cli-unwrapped,
  uv,
}:
let
  # pandas-stubs' tests pull pyiceberg -> geoarrow -> geopandas, whose own tests fail.
  python = python313.override {
    self = python;
    packageOverrides = _: prev: {
      pandas-stubs = prev.pandas-stubs.overridePythonAttrs {
        doCheck = false;
        pythonImportsCheck = [ ]; # imports pandas, which only came from the check inputs
      };
    };
  };
  py = python.pkgs;
  rjieba = callPackage ./rjieba.nix { };
  app = py.buildPythonPackage rec {
    pname = "kirocrew";
    version = "0.12.2";
    format = "wheel";

    src = fetchurl {
      url = "https://github.com/kirodotdev/KiroCrew/releases/download/v${version}/kirocrew-${version}-py3-none-any.whl";
      hash = "sha256-m9fiqA/kE7zZ0ZOXR6pWuK4DHNF6JDi/ngFHaP2wt6g=";
    };

    # Nix sqlite is built with FTS5. pkgs.uv replaces the PyPI uv wheel.
    pythonRemoveDeps = [
      "pysqlite3-binary"
      "uv"
    ];
    # nixpkgs croniter / cron-descriptor are newer than the wheel's upper bounds.
    pythonRelaxDeps = true;

    nativeBuildInputs = [ autoPatchelfHook ];
    # Vendored llama.cpp .so files (in-process embeddings).
    buildInputs = [ stdenv.cc.cc.lib ];

    dependencies = with py; [
      aiohttp
      httpx
      h2 # httpx[http2]
      yarl
      multidict
      slack-sdk
      websockets
      cron-descriptor
      croniter
      pathspec
      jsonschema
      markdown-it-py
      numpy
      rjieba
      snowballstemmer
      tzdata
      jinja2
      typing-extensions
      openpyxl
      python-docx
      pdfplumber
      defusedxml
      qrcode
      pillow
      cryptography
      requests
      pyyaml
      opentelemetry-api
      opentelemetry-sdk
    ];

    # nixpkgs `kiro-cli` is an FHS bwrap wrapper. Crew's sandbox already
    # enters a user+mount namespace and makes `/` private, so that inner
    # `bwrap` dies with "Failed to make / slave". The unwrapped binary is a
    # Nix-linked executable and runs inside the namespace. Its bin/ also holds
    # the sibling `kiro-cli-chat` the CLI execs.
    #
    # Builtin app backends are re-exec'd as `sys.executable -m …`. That
    # interpreter is the bare Nix python; the gateway only sees PyYAML and the
    # rest because this wrapper's site.addsitedir list is in-process. Children
    # keep PYTHONPATH (minimal_env, and `-s` does not drop it), so publish the
    # same site dirs there.
    makeWrapperArgs = [
      "--prefix" "PATH" ":" (lib.makeBinPath [ kiro-cli-unwrapped uv ])
      "--prefix" "PYTHONPATH" ":" "${placeholder "out"}/${py.python.sitePackages}:${py.makePythonPath dependencies}"
      # Unattended spawns refuse a PATH lookup. Pin the same unwrapped binary.
      "--set-default" "KIROCREW_KIRO_BIN" "${kiro-cli-unwrapped}/bin/kiro-cli"
      "--set-default" "SSL_CERT_FILE" "${cacert}/etc/ssl/certs/ca-bundle.crt"
    ];

    # md-notebook only trusts git in /usr/bin and friends (never PATH) and its backend gets a
    # scrubbed env, so MD_NOTEBOOK_GIT_BIN cannot reach it. A store path is immutable, so trust it.
    postInstall = ''
      substituteInPlace $out/${py.python.sitePackages}/kiro_crew/apps/builtins/md_notebook/git_ops.py \
        --replace-fail '    "/opt/homebrew/bin",' '    "/opt/homebrew/bin",
          "${git}/bin",'
    '';

    pythonImportsCheck = [ "kiro_crew" ];

    meta = {
      description = "Persistent local agent workspace (dashboard, schedules, memory)";
      homepage = "https://github.com/kirodotdev/KiroCrew";
      license = lib.licenses.asl20;
      mainProgram = "kirocrew";
      platforms = [ "x86_64-linux" ];
    };
  };

  # The gateway re-execs `sys.executable` for app backends, and md-notebook starts with
  # `python -I`, which ignores PYTHONPATH. Run Crew from an env interpreter so its
  # dependencies sit in that interpreter's own site-packages.
  env = python.withPackages (_: [ app ]);
in
runCommand "kirocrew-${app.version}"
  {
    nativeBuildInputs = [ makeWrapper ];
    inherit (app) meta;
    passthru = { inherit app; };
  }
  ''
    makeWrapper ${env}/bin/python3.13 $out/bin/kirocrew \
      --add-flags "-m kiro_crew" \
      --prefix PATH : ${lib.makeBinPath [ kiro-cli-unwrapped uv ]} \
      --set-default KIROCREW_KIRO_BIN ${kiro-cli-unwrapped}/bin/kiro-cli \
      --set-default SSL_CERT_FILE ${cacert}/etc/ssl/certs/ca-bundle.crt
  ''
