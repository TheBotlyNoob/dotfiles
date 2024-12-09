{ ... }@flakeInputs:
{ config, pkgs, ... }@inputs:
{
  # Bootloader.
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;
  };
  networking.hostName = "fbi-van-laptop";
}
