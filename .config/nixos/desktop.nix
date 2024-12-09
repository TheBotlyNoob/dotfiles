{ ... }@flakeInputs:
{ config, pkgs, ... }@inputs:
{
  networking.hostName = "JJ-Desktop";

  # Bootloader.
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;
  };
}
