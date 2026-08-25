{ config, ... }:
{
  programs.ssh.extraConfig = ''
    Host github.com
      IdentityFile ~/.ssh/id_ed25519
      IdentitiesOnly yes

    Host *
      AddKeysToAgent yes
      IdentityAgent ~/.1password/agent.sock

    Host hardened-vm
      User ${config.my.username}
  '';
}
