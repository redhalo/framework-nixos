{ config, pkgs, lib, ... }:

let
  # Custom Base16 scheme
  robertsBase16 = import ./themes/robert-base16.nix;

  # Stylix-colored wallpaper using lutgen
  wallpaper =
    with config.lib.stylix.colors;
    pkgs.runCommand "wallpaper.png" { } ''
      ${pkgs.lutgen}/bin/lutgen apply ${./wallpapers/wallpaper.jpg} -o $out \
        --lum 0.5 -- \
        ${base00} ${base01} ${base02} ${base03} ${base04} ${base05} ${base06} \
        ${base07} ${base08} ${base09} ${base0A} ${base0B} ${base0C} ${base0D} \
        ${base0E} ${base0F}
    '';

  # URI used by GNOME/GDM for background
  wallpaperUri = "file://${wallpaper}";
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  ########################################
  # Basic system settings
  ########################################

  networking.hostName = "framework-13";
  networking.networkmanager.enable = true;

  time.timeZone = lib.mkDefault "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME = "en_US.UTF-8";
  };

  ########################################
  # Nixpkgs & Nix
  ########################################

  nixpkgs.config = {
    allowUnfree = true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Nix housekeeping: auto GC + optimise + nix-index
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    optimise.automatic = true;
  };

  programs.nix-index.enable = true;
  #programs.nix-index-database.comma.enable = true;
  #programs.command-not-found.enable = false;

  ########################################
  # Bootloader + Plymouth
  ########################################

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };

  boot.loader.efi.canTouchEfiVariables = true;

  # Hide boot menu unless a key is held
  boot.loader.timeout = 0;

  # Required for Plymouth with systemd-boot
  boot.initrd.systemd.enable = true;

  # Enable Plymouth with default theme
  boot.plymouth.enable = true;

  # Quiet/silent boot
  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "systemd.show_status=0"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
  ];

  boot.consoleLogLevel = 0;

  ########################################
  # GNOME + GDM + Wayland
  ########################################

  services.displayManager = {
    gdm.enable = true;
    gdm.wayland = true;
  };

  services.xserver.xkb.layout = "us";

  services.desktopManager.gnome.enable = true;


  programs.xwayland.enable = true;
  programs.dconf.enable = true;

  # Trim GNOME's default apps a bit
  environment.gnome.excludePackages = with pkgs; [
    # We use Ghostty, so drop the stock terminals
    gnome-terminal
    gnome-console

    # We use Firefox, so drop GNOME Web
    epiphany  # GNOME Web

    # Extra apps we don't need
    gnome-characters
    gnome-contacts
    gnome-maps
    gnome-clocks
    gnome-tour
    gnome-music
    #gnome-videos
    gnome-software
  ];

  # GNOME & GDM defaults via gsettings (GDM reads these)
  programs.dconf.profiles.gdm = {
    databases = [{
      lockAll = true;
      settings = {
        # Background/lockscreen/GDM use same Stylix-colored wallpaper
        "org/gnome/desktop/background" = {
          picture-uri = wallpaperUri;
          picture-uri-dark = wallpaperUri;
        };

        "org/gnome/desktop/screensaver" = {
          picture-uri = wallpaperUri;
        };

        # Interface defaults
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          clock-format = "12h";
          show-clock-date = false;
        };
      };
    }];
  };

  ########################################
  # Audio (PipeWire)
  ########################################

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  ########################################
  # Bluetooth / firmware / microcode
  ########################################

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  hardware.enableAllFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  ########################################
  # Power management / laptop tweaks
  ########################################

  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;

  services.upower.enable = true;

  services.logind.settings.Login = {
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower= "suspend";
  };

  ########################################
  # Users
  ########################################
  
  #Don't allow mutation of users outside of the config.
  users.mutableUsers = false;
  users.users.root.initialHashedPassword = "$y$j9T$bzMV86c8qJfFTEVKgVeFH.$wala41vF7kWKzZ3PWo8iWEp2RtuWEehh0WRHCw0NyiA";

  users.users."robert" = {
    initialHashedPassword = "$y$j9T$bzMV86c8qJfFTEVKgVeFH.$wala41vF7kWKzZ3PWo8iWEp2RtuWEehh0WRHCw0NyiA";
    isNormalUser = true;
    description  = "Robert";
    extraGroups  = [ "wheel" "networkmanager" "audio" "video" ];
    openssh.authorizedKeys.keys = [ ];
  };

  ########################################
  # Shell
  ########################################

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  ########################################
  # 1Password (CLI + GUI + shell plugins)
  ########################################

  programs._1password.enable = true;

  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "robert" ];
  };

  #programs._1password-shell-plugins = {
  #  enable = true;
  #  plugins = with pkgs; [
  #    gh
  #  ];
  #};

  # Firefox as allowed browser for 1Password integration
  environment.etc."1password/custom_allowed_browsers" = {
    text = ''
      firefox
    '';
    mode = "0644";
  };

  ########################################
  # Firefox (system-level policies)
  ########################################

  programs.firefox = {
    enable = true;

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DisablePocket = true;
      DisableFirefoxAccounts = false;
      DisableFirefoxScreenshots = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DontCheckDefaultBrowser = true;
      DisplayBookmarksToolbar = "newtab";
      DisplayMenuBar = "default-off";
      SearchBar = "unified";
    };
  };

  ########################################
  # Gaming: Steam + Proton + Gamescope + MangoHud + Gamemode
  ########################################

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;

    gamescopeSession.enable = true;
    extest.enable = true;
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  programs.gamemode.enable = true;

  ########################################
  # Packages (system-wide)
  ########################################

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    gnomeExtensions.appindicator

    protonup-qt
  ];

  ########################################
  # Networking / printing / mDNS / firewall
  ########################################

  networking.firewall.enable = true;

  services.printing.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  ########################################
  # Firmware updates
  ########################################

  services.fwupd.enable = true;

  ########################################
  # Graphics
  ########################################

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  ########################################
  # Timezone auto-detection (GNOME + system)
  ########################################

  services.automatic-timezoned.enable = true;

  services.geoclue2 = {
    enable = true;
    geoProviderUrl = "https://beacondb.net/v1/geolocate";
  };

  ########################################
  # Btrfs maintenance
  ########################################

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/nix" "/persist" ];
  };

  ########################################
  # Impermanence: /persist backing store
  ########################################

  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;

    # System-level persistence
    directories = [
      "/etc/nixos"
      "/etc/NetworkManager/system-connections"
      "/etc/gdm"
      "/var/log"
      "/var/lib/fprint"
      "/var/lib/systemd"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/NetworkManager"
      "/var/lib/AccountsService" # Needed to show profile picture of user
    ];

    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];

    # User-level persistence for robert (incl. Steam)
    users.robert = {
      directories = [
        "Documents"
        "Downloads"
        "Music"
        "Pictures"
        "Videos"

        ".config"
        ".local/share"
        ".local/state"
        ".ssh"
        ".gnupg"

	".cache/mozilla/firefox"
        ".mozilla/firefox"

        ".local/share/Steam"
        ".steam"
      ];

      files = [ ];
    };
  };

  ########################################
  # Stylix theming
  ########################################

  stylix = {
    enable = true;
    polarity = "dark";

    base16Scheme = robertsBase16;
    image = wallpaper;

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };

    cursor = {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors";
      size = 24;
    };

    icons = {
      enable = true;
      package = pkgs.vimix-icon-theme;
      dark = "Vimix";
      light = "Vimix";
    };


    homeManagerIntegration = {
      autoImport = true;
      followSystem = true;
    };

    targets = {
      # Don't theme console or Plymouth
      console.enable = false;
      plymouth.enable = false;
    };
  };

  ########################################
  # VS Code
  ########################################

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    #enableUpdateCheck = false;
    #enableExtensionUpdateCheck = false;
  };

  ########################################
  # Required for upgrades
  ########################################

  system.stateVersion = "24.05";
}
