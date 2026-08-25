{
  lib,
  python3,
  runCommand,
  writeShellApplication,
  kiroGatewaySrc,
}:
let
  patchScript = ./patch-cursor.py;

  src = runCommand "kiro-gateway-src-patched" {} ''
    cp -r ${kiroGatewaySrc} $out
    chmod -R u+w $out
    ${lib.getExe python3} ${patchScript} $out
  '';

  python = python3.withPackages (ps: with ps; [
    fastapi
    uvicorn
    httpx
    loguru
    python-dotenv
    tiktoken
  ]);
in
writeShellApplication {
  name = "kiro-gateway";
  runtimeInputs = [ python ];
  text = ''
    export PYTHONPATH="${src}''${PYTHONPATH:+:''$PYTHONPATH}"
    exec ${python}/bin/python ${src}/main.py "$@"
  '';
}
