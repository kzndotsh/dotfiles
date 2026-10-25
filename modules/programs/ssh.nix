{ config, ... }:
{
  # Stock is true: an Include of systemd's ssh proxy (ssh vsock/N, unix/...) in /etc/ssh/ssh_config.
  # Off for the same reason as libvirtd.sshProxy: inside a user-namespace sandbox ssh refuses the store file.
  programs.ssh.systemd-ssh-proxy.enable = false;

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
