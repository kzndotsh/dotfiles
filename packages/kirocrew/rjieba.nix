# Not in nixpkgs. Pinned to kirocrew's exact requirement (rjieba==0.2.1).
# Rust abi3 wheel, so no maturin build; autoPatchelf handles the .so.
{
  python313,
  autoPatchelfHook,
  stdenv,
}:
python313.pkgs.buildPythonPackage rec {
  pname = "rjieba";
  version = "0.2.1";
  format = "wheel";

  src = python313.pkgs.fetchPypi {
    inherit pname version format;
    dist = "cp38";
    python = "cp38";
    abi = "abi3";
    platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
    hash = "sha256-5L4320qZFiyZzFW06T4CTFBBplpqs7X9oMWL6yHrI08=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];

  pythonImportsCheck = [ "rjieba" ];
}
