# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ ... }@flakeInputs:
{ config, pkgs, ... }@inputs:
let
  spicePkgs = flakeInputs.spicetify-nix.legacyPackages.${pkgs.system};
in

{
  imports =
    [ # Include the results of the hardware scan.
      flakeInputs.spicetify-nix.nixosModules.default
      ./hardware-configuration.nix
    ];

  # use zen kernel for waydroid
  boot.kernelPackages = pkgs.linuxPackages_zen;

  boot.loader.timeout = 1;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = ["ntfs"];
  boot.tmp.useTmpfs = true;

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-old";
  };
  
  networking.hostName = "JJ-Desktop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  programs.hyprland.enable = true;
  services.displayManager.sddm = {
    enable = true;
    # wayland.enable = true;
    theme = "catpuccin-mocha";
  };
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  programs.nix-ld.enable = true;

  hardware.graphics.enable32Bit = true; # For 32 bit applications

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
    wireplumber.configPackages = [
    	(pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
    		bluez_monitor.properties = {
    			["bluez5.enable-sbc-xq"] = true,
    			["bluez5.enable-msbc"] = true,
    			["bluez5.enable-hw-volume"] = true,
    			["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
    		}
    	'')
    ];
    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;


  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.mononoki
    maple-mono-NF
    cascadia-code
  ];

  programs.spicetify = 
      {
        enable = true;
        enabledExtensions = with spicePkgs.extensions; [
          groupSession
          shuffle # shuffle+ (special characters are sanitized out of extension names)
          showQueueDuration
          autoVolume
          songStats
          history
          betterGenres
          fullAppDisplay
          addToQueueTop
          keyboardShortcut
          oldSidebar
        ];
        enabledCustomApps = with spicePkgs.apps; [
          ncsVisualizer
        ];

        theme = spicePkgs.themes.catppuccin;
	colorScheme = "mocha";
      };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jj = {
    isNormalUser = true;
    description = "Jay Jackson";
    extraGroups = [ "networkmanager" "wheel" "dialout" "docker" ];
    packages = with pkgs; [
      firefox
      microsoft-edge
      vscode
      devenv
      direnv
      vesktop
      todoist-electron
      bottles
      prismlauncher
      nushell
      signal-desktop
      nwg-displays
      docker
      hyprshot
      github-cli
      devenv
      clang
      thefuck
      zellij
      yadm
      playerctl
      swww
      file
      swayimg
      lsd
      bat
      jq
      parallel
      dunst
      waybar
      (python3.withPackages(ps: with ps; [ pygobject3 ]))
    ];
  };
  services.displayManager.autoLogin.user = "jj";
  nix.settings.trusted-users = [ "jj" ];

  security.polkit.enable = true;
  programs.dconf.enable = true;

  networking = {
    firewall = {
      enable = true;
      interfaces."tun0" = {
        allowedTCPPorts = [ 4444 ];
        allowedUDPPorts = [ 4444 ];
      };
    };
  };

  virtualisation.waydroid.enable = true;

  programs.fish.enable = true;

  programs.bash = {
    interactiveShellInit = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };


  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     git
     neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     wget
     curl
     # gnomeExtensions.pop-shell
     # gnome3.gnome-tweaks
     fd
     ripgrep
     gcc
     fira-code
     pavucontrol
     kitty
     rofi-wayland
     fish
     fishPlugins.z
     fishPlugins.done
     fishPlugins.tide
     ocl-icd
     opencl-headers
     clinfo
     distrobox
     dive # look into docker image layers
     podman-tui # status of containers in the terminal
     cryptsetup
     killall

     polkit_gnome
     udiskie
     wl-clipboard
     networkmanagerapplet
     gettext

     glib
     adwaita-icon-theme

     (catppuccin-sddm.override {
       flavor = "mocha";
       font  = "Mononoki Nerd Font";
       fontSize = "12";
       background = "${config.users.users.jj.home}/wallpapers/sci-fi/WALL-E/WALLY.jpg";
       loginBackground = true;
     })
  ];

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };


  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 4444 ];
  # networking.firewall.allowedUDPPorts = [ 4444 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
