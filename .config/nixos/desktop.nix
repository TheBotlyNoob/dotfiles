{ ... }@flakeInputs:
{ config, pkgs, ... }@inputs:
{
  networking.hostName = "JJ-Desktop";

  services.dnsmasq = {
      enable = true;
      settings.address = [ "/stuff.local/127.0.0.1" ];
  };

  # Bootloader.
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;
  };
}
