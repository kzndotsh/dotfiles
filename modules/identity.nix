# NixOS wrapper around lib/identity.nix. Defaults come from the attrset (not config.users).
{ lib, identity, ... }:
{
  options.my = {
    username = lib.mkOption { type = lib.types.str; default = identity.username; };
    home = lib.mkOption { type = lib.types.str; default = identity.home; };
    hostName = lib.mkOption { type = lib.types.str; default = identity.hostName; };
    domain = lib.mkOption { type = lib.types.str; default = identity.domain; };
    acmeEmail = lib.mkOption { type = lib.types.str; default = identity.acmeEmail; };
    gitName = lib.mkOption { type = lib.types.str; default = identity.gitName; };
    gitEmail = lib.mkOption { type = lib.types.str; default = identity.gitEmail; };
    gitUsername = lib.mkOption { type = lib.types.str; default = identity.gitUsername; };
    sshKey = lib.mkOption { type = lib.types.str; default = identity.sshKey; };
    dotfilesDir = lib.mkOption { type = lib.types.str; default = identity.dotfilesDir; };
    secretsDir = lib.mkOption { type = lib.types.str; default = identity.secretsDir; };
  };
}
