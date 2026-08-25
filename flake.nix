{
  description = "dotfiles";

  # ─── Inputs ─────────────────────────────────────────────────────────────
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    wrappers = {
      url = "github:hermetic-foundation/nix-wrappers";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    NixVirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    terranix = {
      url = "github:terranix/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kiro-gateway = {
      url = "github:jwadow/kiro-gateway";
      flake = false;
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    findDupeTracks = {
      url = "github:veryboringhwl/spicetify-extensions";
      flake = false;
    };

    cratedigger = {
      url = "github:kzndotsh/spicetify-cratedigger";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      identity = import ./lib/identity.nix;
      specialArgs = { inherit inputs self identity; };

      vpsId = identity // {
        hostName = identity.vpsHostName;
        sopsFile = ./secrets/vps.yaml;
      };

      mkVps = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs self; identity = vpsId; };
        modules = [
          ./modules/identity.nix
          ./hosts/vps/configuration.nix
          inputs.disko.nixosModules.disko
          inputs.sops-nix.nixosModules.sops
          "${nixpkgs}/nixos/modules/misc/nixpkgs/read-only.nix"
          { nixpkgs.pkgs = pkgs; }
        ];
      };

      tf = inputs.terranix.lib.terranixConfiguration {
        inherit system;
        modules = [ ./infra ];
        extraArgs = { identity = vpsId; };
      };

      sourceEnv = ''
        if [[ -f "$ENV" ]]; then
          set -a
          # shellcheck disable=SC1091
          source "$ENV"
          set +a
        fi
      '';

      requireHetznerCloudflare = ''
        : "''${HCLOUD_TOKEN:?missing HCLOUD_TOKEN — copy .env.example to .env.kzn}"
        : "''${CLOUDFLARE_API_TOKEN:?missing CLOUDFLARE_API_TOKEN}"
        : "''${TF_VAR_cloudflare_zone_id:?missing TF_VAR_cloudflare_zone_id}"
        : "''${TF_VAR_cloudflare_account_id:?missing TF_VAR_cloudflare_account_id — Cloudflare account ID (Zero Trust)}"
      '';

      tofuPrep = ''
        ROOT="$(git rev-parse --show-toplevel)"
        ENV="$ROOT/.env.kzn"
        WORK="$ROOT/infra/state/kzn"
        mkdir -p "$WORK"
        cd "$WORK"
        ${sourceEnv}
        ${requireHetznerCloudflare}
        rm -f config.tf.json
        cp "${tf}" config.tf.json
        ${pkgs.opentofu}/bin/tofu init -input=false
      '';

      mkTofuApp = name: command: {
        type = "app";
        program = toString (pkgs.writers.writeBash name ''
          set -euo pipefail
          ${tofuPrep}
          ${pkgs.opentofu}/bin/tofu ${command} "$@"
        '');
      };

      desktop = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          ./modules/identity.nix
          ./hosts/desktop/configuration.nix
          inputs.wrappers.nixosModules.system-wrappers
          inputs.NixVirt.nixosModules.default
          inputs.spicetify-nix.nixosModules.spicetify
          "${nixpkgs}/nixos/modules/misc/nixpkgs/read-only.nix"
          { nixpkgs.pkgs = pkgs; }
        ];
      };

      hardenedVm = nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        modules = [
          ./modules/identity.nix
          ./hosts/hardened-vm/configuration.nix
          inputs.disko.nixosModules.disko
          "${nixpkgs}/nixos/modules/misc/nixpkgs/read-only.nix"
          { nixpkgs.pkgs = pkgs; }
        ];
      };
    in
    {
      packages.${system} = {
        kiro-gateway = import ./packages/kiro-gateway {
          inherit (pkgs) lib python3 runCommand writeShellApplication;
          kiroGatewaySrc = inputs.kiro-gateway;
        };
        crankshaft = pkgs.callPackage ./packages/crankshaft { };
        session-desktop = pkgs.callPackage ./packages/session-desktop { };
      };

      nixosConfigurations = {
        ${identity.hostName} = desktop;
        hardened-vm = hardenedVm;
        vps = mkVps;
      };

      apps.${system} = {
        vm-install = {
          type = "app";
          program = toString (pkgs.writeShellScript "vm-install" ''
            set -e

            IMG="/var/lib/libvirt/images/hardened-vm/hardened-vm.qcow2"

            echo "Building hardened-vm disk image with LUKS..."
            echo "Enter LUKS password for the VM:"
            read -s LUKS_PASS
            echo "$LUKS_PASS" > /tmp/luks-password

            nix build .#nixosConfigurations.hardened-vm.config.system.build.diskoImages \
              --out-link /tmp/hardened-vm-build

            echo "Installing image into libvirt pool..."
            sudo mkdir -p /var/lib/libvirt/images/hardened-vm
            sudo cp --reflink=auto /tmp/hardened-vm-build/main.raw "$IMG.raw"
            sudo ${pkgs.qemu}/bin/qemu-img convert \
              -f raw -O qcow2 \
              -o cluster_size=2M,preallocation=metadata,lazy_refcounts=on \
              "$IMG.raw" "$IMG"
            sudo rm -f "$IMG.raw"
            rm -f /tmp/luks-password /tmp/hardened-vm-build

            echo "Done. Start the VM from virt-manager."
            echo "LUKS passphrase will be required at boot."
          '');
        };

        vps-plan = mkTofuApp "vps-plan" "plan";
        vps-apply = mkTofuApp "vps-apply" "apply";
        vps-destroy = mkTofuApp "vps-destroy" "destroy";

        vps-install = {
          type = "app";
          program = toString (pkgs.writeShellScript "vps-install" ''
            set -euo pipefail
            ROOT="$(git rev-parse --show-toplevel)"
            HOST="''${1:-root@${identity.ipv4}}"
            AGE_KEY="${identity.secretsDir}/${identity.ageKey}"
            INITRD="$ROOT/${identity.initrdKeyRel}"
            cd "$ROOT"

            echo "Enter LUKS password for the kzn VPS:"
            read -s LUKS_PASS

            TMPDIR=$(mktemp -d)
            echo "$LUKS_PASS" > "$TMPDIR/luks-password"

            mkdir -p "$TMPDIR/etc/ssh" "$(dirname "$INITRD")"
            if [ ! -f "$INITRD" ]; then
              ssh-keygen -t ed25519 -f "$INITRD" -N "" -q
              echo "Generated initrd SSH host key at $INITRD"
            fi
            cp "$INITRD" "$TMPDIR/etc/ssh/ssh_host_ed25519_key"
            chmod 600 "$TMPDIR/etc/ssh/ssh_host_ed25519_key"

            mkdir -p "$TMPDIR/var/lib/sops-nix"
            if [ ! -f "$AGE_KEY" ]; then
              echo "Missing $AGE_KEY (VPS sops age key)" >&2
              exit 1
            fi
            cp "$AGE_KEY" "$TMPDIR/var/lib/sops-nix/key.txt"
            chmod 600 "$TMPDIR/var/lib/sops-nix/key.txt"

            echo "Installing NixOS on $HOST via nixos-anywhere (wipes the disk, flake path:$ROOT#vps)..."
            nix run github:nix-community/nixos-anywhere -- \
              --flake "path:$ROOT#vps" \
              --disk-encryption-keys /tmp/luks-password "$TMPDIR/luks-password" \
              --extra-files "$TMPDIR" \
              "$HOST"

            rm -rf "$TMPDIR"
          '');
        };

        vps-switch = {
          type = "app";
          program = toString (pkgs.writeShellScript "vps-switch" ''
            set -euo pipefail
            ROOT="$(git rev-parse --show-toplevel)"
            HOST="''${1:-root@${identity.ipv4}}"
            echo "Switching kzn VPS..."
            nixos-rebuild switch --flake "path:$ROOT#vps" --target-host "$HOST" --use-remote-sudo
          '');
        };

        vps-tunnels-sync = {
          type = "app";
          program = toString (pkgs.writers.writeBash "vps-tunnels-sync" ''
            set -euo pipefail
            ROOT="$(git rev-parse --show-toplevel)"
            ENV="$ROOT/.env.kzn"
            WORK="$ROOT/infra/state/kzn"
            DEST="${identity.secretsDir}/cloudflared"
            SOPS_OUT="$ROOT/secrets/cloudflared.yaml"

            mkdir -p "$WORK" "$DEST"
            chmod 700 "$DEST"
            cd "$WORK"
            ${sourceEnv}
            ${requireHetznerCloudflare}

            rm -f config.tf.json
            cp "${tf}" config.tf.json
            ${pkgs.opentofu}/bin/tofu init -input=false

            PLAIN="$(mktemp)"
            trap 'rm -f "$PLAIN"' EXIT
            ALL="$(${pkgs.opentofu}/bin/tofu output -json)"
            ${pkgs.jq}/bin/jq '{kiro: .kiro.value, files: .files.value}' <<<"$ALL" > "$PLAIN"

            for name in kiro files; do
              ${pkgs.jq}/bin/jq -c --arg n "$name" '.[$n]' "$PLAIN" > "$DEST/$name.json"
              chmod 600 "$DEST/$name.json"
            done

            ${pkgs.sops}/bin/sops --encrypt --input-type json --output-type yaml \
              --filename-override "$SOPS_OUT" "$PLAIN" > "$SOPS_OUT"

            echo "Wrote $DEST/{kiro,files}.json and $SOPS_OUT"
            echo "Restart user units: systemctl --user restart cloudflared-kiro cloudflared-files"
          '');
        };
      };

      formatter.${system} = pkgs.nixfmt;
    };
}
