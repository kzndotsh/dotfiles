{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wl-video-idle-inhibit";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "sameer";
    repo = "wl-video-idle-inhibit";
    rev = finalAttrs.version;
    hash = "sha256-yr8eM3qqWn/Lhwuoja4guB+qGP45EblH49aIEM2gVaU=";
  };

  # Upstream pins Smithay wayland-rs via git; vendor lock + hashes for sandbox builds.
  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "wayland-backend-0.1.0-beta.10" = "sha256-TE+q5tmKid1FQP1R2i5Mp6AOi03v8AGL1W9TvSj67tE=";
      "wayland-client-0.30.0-beta.10" = "sha256-TE+q5tmKid1FQP1R2i5Mp6AOi03v8AGL1W9TvSj67tE=";
      "wayland-protocols-0.30.0-beta.10" = "sha256-TE+q5tmKid1FQP1R2i5Mp6AOi03v8AGL1W9TvSj67tE=";
      "wayland-scanner-0.30.0-beta.10" = "sha256-TE+q5tmKid1FQP1R2i5Mp6AOi03v8AGL1W9TvSj67tE=";
      "wayland-sys-0.30.0-beta.10" = "sha256-TE+q5tmKid1FQP1R2i5Mp6AOi03v8AGL1W9TvSj67tE=";
    };
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ wayland ];

  meta = {
    description = "Inhibit Wayland idle while a /dev/video* device is open";
    homepage = "https://github.com/sameer/wl-video-idle-inhibit";
    license = with lib.licenses; [
      mit
      asl20
    ];
    mainProgram = "wl-video-idle-inhibit";
    platforms = lib.platforms.linux;
  };
})
