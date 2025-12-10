{ config, pkgs, lib, ... }:

let
  # Recolored profile image for ~/.face using Stylix base16 colors
  stylixFace =
    with config.lib.stylix.colors;
    pkgs.runCommand "robert-face.png" { } ''
      ${pkgs.lutgen}/bin/lutgen apply ${./avatars/profile.png} -o $out -- \
        ${base00} ${base01} ${base02} ${base03} ${base04} ${base05} ${base06} \
        ${base07} ${base08} ${base09} ${base0A} ${base0B} ${base0C} ${base0D} \
        ${base0E} ${base0F}
    '';
in
{
  home.username = "robert";
  home.homeDirectory = "/home/robert";

  programs.home-manager.enable = true;
  
  ########################################
  # systemd user units
  ########################################

  systemd.user.startServices = "sd-switch";

  ########################################
  # Packages (CLI + Python dev + GNOME extensions)
  ########################################

  home.packages =
    (with pkgs; [
      neovim
      htop
      jq
      ripgrep
      fd

      # Python toolchain
      python315
      pipx
      virtualenv
      poetry

      black
      ruff
      mypy
    ])
    ++ (with pkgs.gnomeExtensions; [
      autohide-battery
      blur-my-shell
      caffeine
      open-bar
      paperwm
      weather-or-not
    ]);

  ########################################
  # direnv + nix-direnv
  ########################################

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  ########################################
  # Git
  ########################################

  programs.git = {
    enable = true;
    settings.user.name  = "Robert McCoy";
    settings.user.email = "robertmccoy1981@gmail.com"; # change this
  };

  ########################################
  # zsh + oh-my-zsh
  ########################################

  programs.zsh = {
    enable = true;

    history.path = "${config.xdg.dataHome}/zsh/zsh_history";

    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [
        "git"
        "sudo"
        "z"
      ];
    };

    shellAliases = {
      ll = "ls -lah";
      gs = "git status";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
    };

    initContent = lib.mkOrder 1200 ''
      HISTSIZE=5000
      SAVEHIST=5000
      setopt EXTENDED_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_VERIFY

      export EDITOR="nvim"
    '';
  };
  
  ########################################
  # Ghostty terminal
  ########################################

  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    enableZshIntegration = true;

    settings = {
      "font-family" = "FiraCode Nerd Font Mono";
      "font-size" = 11;
    };
  };
  
  ########################################
  # Gaming: Steam + Proton + Gamescope + MangoHud + Gamemode
  ########################################

  programs.mangohud = {
    enable = true;
    enableSessionWide = false;
    settings = {
      full = true;
      fps_limit = 0;
      gpu_stats = true;
      cpu_stats = true;
      frametime = true;
      position = "top-right";
    };
  };

  ########################################
  # GNOME dconf (with Stylix-powered colors)
  ########################################

  dconf.enable = true;
  dconf.settings = with config.lib.stylix.colors; {
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-schedule-automatic = true;
      night-light-temperature = 2700;
    };

    "org/gnome/desktop/datetime" = {
      automatic-timezone = true;
    };

    "org/gnome/desktop/interface" = {
      clock-format = "12h";
      show-clock-date = false;
    };

    "org/gnome/desktop/notifications" = {
      show-in-lock-screen = false;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = false;
    };

    "org/gnome/desktop/screensaver" = {
      lock-enabled = false;
    };

    "org/gnome/desktop/wm/keybindings" = lib.mkDefault {
      ## Workspace switching ##
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      switch-to-workspace-5 = [ "<Super>5" ];
      switch-to-workspace-6 = [ "<Super>6" ];
      switch-to-workspace-7 = [ "<Super>7" ];
      switch-to-workspace-8 = [ "<Super>8" ];
      switch-to-workspace-9 = [ "<Super>9" ];
      switch-to-workspace-10 = [ "<Super>0" ];
      switch-to-workspace-left = [ ];
      switch-to-workspace-right = [ ];
      switch-to-workspace-up = [ ];
      switch-to-workspace-down = [ ];
      switch-to-workspace-last = [ ];

      ## Application/Window switching ##
      switch-group = [
        "<Super>Above_Tab"
        "<Alt>Above_Tab"
      ];
      switch-group-backward = [
        "<Shift><Super>Above_Tab"
        "<Shift><Alt>Above_Tab"
      ];
      switch-applications = [ ];
      switch-applications-backward = [ ];
      switch-windows = [ ];
      switch-windows-backward = [ ];
      switch-panels = [ "<Control><Alt>Tab" ];
      switch-panels-backward = [ "<Shift><Control><Alt>Tab" ];

      ## Direct cycling ##
      cycle-group = [ ];
      cycle-group-backward = [ ];
      cycle-windows = [ ];
      cycle-windows-backward = [ ];
      cycle-panels = [ ];
      cycle-panels-backward = [ ];

      ## Window management ##
      show-desktop = [ ];
      panel-main-menu = [ ];
      panel-run-dialog = [ "<Alt>F2" ];
      set-spew-mark = [ ];
      activate-window-menu = [ ];
      toggle-fullscreen = [ ];
      toggle-maximized = [ ];
      toggle-above = [ ];
      maximize = [ ];
      unmaximize = [ ];
      minimize = [ ];
      close = [ ];
      begin-move = [ ];
      begin-resize = [ ];
      toggle-on-all-workspaces = [ ];
      move-to-workspace-1 = [ "<Shift><Super>1" ];
      move-to-workspace-2 = [ "<Shift><Super>2" ];
      move-to-workspace-3 = [ "<Shift><Super>3" ];
      move-to-workspace-4 = [ "<Shift><Super>4" ];
      move-to-workspace-5 = [ "<Shift><Super>5" ];
      move-to-workspace-6 = [ "<Shift><Super>6" ];
      move-to-workspace-7 = [ "<Shift><Super>7" ];
      move-to-workspace-8 = [ "<Shift><Super>8" ];
      move-to-workspace-9 = [ "<Shift><Super>9" ];
      move-to-workspace-10 = [ "<Shift><Super>0" ];
      move-to-workspace-last = [ ];
      move-to-workspace-left = [ ];
      move-to-workspace-right = [ ];
      move-to-workspace-up = [ ];
      move-to-workspace-down = [ ];
      move-to-monitor-left = [ ];
      move-to-monitor-right = [ ];
      move-to-monitor-up = [ ];
      move-to-monitor-down = [ ];
      raise-or-lower = [ ];
      raise = [ ];
      lower = [ ];
      maximize-vertically = [ ];
      maximize-horizontally = [ ];
      move-to-corner-nw = [ ];
      move-to-corner-ne = [ ];
      move-to-corner-sw = [ ];
      move-to-corner-se = [ ];
      move-to-side-n = [ ];
      move-to-side-s = [ ];
      move-to-side-e = [ ];
      move-to-side-w = [ ];
      move-to-center = [ ];
      always-on-top = [ ];

      ## Input switching ##
      switch-input-source = [ ];
      switch-input-source-backward = [ ];
    };

    "org/gnome/shell/keybindings" = lib.mkDefault {
      switch-to-application-1 = [ ];
      switch-to-application-2 = [ ];
      switch-to-application-3 = [ ];
      switch-to-application-4 = [ ];
      switch-to-application-5 = [ ];
      switch-to-application-6 = [ ];
      switch-to-application-7 = [ ];
      switch-to-application-8 = [ ];
      switch-to-application-9 = [ ];
      switch-to-application-10 = [ ];
    };

    "org/gnome/shell/extensions/paperwm/keybindings" = lib.mkDefault {
      center = [ "<Super>c" ];
      center-horizontally = [ ];
      center-vertically = [ ];
      close-window = [ "<Super>q" ];
      cycle-height = [ "<Alt><Super>Up" ];
      cycle-height-backwards = [ "<Alt><Super>Down" ];
      cycle-width = [ "<Alt><Super>Right" ];
      cycle-width-backwards = [ "<Alt><Super>Left" ];
      live-alt-tab = [ "<Alt>Tab" ];
      live-alt-tab-backward = [ ];
      live-alt-tab-scratch = [ ];
      live-alt-tab-scratch-backward = [ ];
      move-down = [ "<Shift><Super>Down" ];
      move-down-workspace = [ "<Control><Super>Down" ];
      move-left = [ "<Shift><Super>Left" ];
      move-monitor-above = [ ];
      move-monitor-below = [ ];
      move-monitor-left = [ "<Control><Super>Left" ];
      move-monitor-right = [ "<Control><Super>Right" ];
      move-previous-workspace = [ ];
      move-previous-workspace-backward = [ ];
      move-right = [ "<Shift><Super>Right" ];
      move-space-monitor-above = [ ];
      move-space-monitor-below = [ ];
      move-space-monitor-left = [ ];
      move-space-monitor-right = [ ];
      move-up = [ "<Shift><Super>Up" ];
      move-up-workspace = [ "<Control><Super>Up" ];
      new-window = [ "<Super>n" ];
      previous-workspace = [ ];
      previous-workspace-backward = [ ];
      swap-monitor-above = [ ];
      swap-monitor-below = [ ];
      swap-monitor-left = [ ];
      swap-monitor-right = [ ];
      switch-down-workspace = [ "<Super>Page_Down" ];
      switch-focus-mode = [ "<Alt><Super>a" ];
      switch-monitor-above = [ ];
      switch-monitor-below = [ ];
      switch-monitor-left = [ ];
      switch-monitor-right = [ ];
      switch-next = [ ];
      switch-open-window-position = [ ];
      switch-previous = [ ];
      switch-up-workspace = [ "<Super>Page_Up" ];
      take-window = [ ];
      toggle-maximize-width = [ ];
      toggle-scratch = [ "<Super>BackSpace" ];
      toggle-scratch-layer = [ "<Control><Super>BackSpace" ];
      toggle-scratch-window = [ ];
      toggle-top-and-position-bar = [ ];
    };

    "org/gnome/mutter" = {
      check-alive-timeout = 60000;
    };

    "org/gnome/shell" = {
      enabled-extensions = [
        "caffeine@patapon.info"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "weatherornot@somepaulo.github.io"
        "paperwm@paperwm.github.com"
        "blur-my-shell@aunetx"
        "autohide-battery@sitnik.ru"
        "openbar@neuromorph"
      ];
      favorite-apps = [
        "firefox.desktop"
        "com.mitchellh.ghostty.desktop"
        "org.gnome.Nautilus.desktop"
        "spotify.desktop"
        "steam.desktop"
      ];
    };

    "org/gnome/shell/desktop/wm/preferences" = {
      button-layout = ":close";
    };

    # Blur my shell pipelines, using Stylix colors
    "org/gnome/shell/extensions/blur-my-shell" = with lib.gvariant; {
      pipelines = [
        (mkDictionaryEntry "pipeline_default" ([
          (mkDictionaryEntry "name" (mkVariant "Default"))
          (mkDictionaryEntry "effects" (mkVariant [
            (mkVariant [
              (mkDictionaryEntry "type" (mkVariant "native_static_gaussian_blur"))
              (mkDictionaryEntry "id" (mkVariant "effect_000000000000"))
              (mkDictionaryEntry "params" (mkVariant [
                (mkDictionaryEntry "radius" (mkVariant 30.0))
                (mkDictionaryEntry "brightness" (mkVariant 1.0))
                (mkDictionaryEntry "unscaled_radius" (mkVariant 30.0))
              ]))
            ])
            (mkVariant [
              (mkDictionaryEntry "type" (mkVariant "color"))
              (mkDictionaryEntry "id" (mkVariant "effect_000000000003"))
              (mkDictionaryEntry "params" (mkVariant [
                (mkDictionaryEntry "color" (mkVariant ([
                  "${base01-dec-r}" "${base01-dec-g}" "${base01-dec-b}" "0.6"
                ])))
              ]))
            ])
          ]))
        ]))

        (mkDictionaryEntry "pipeline_default_rounded" ([
          (mkDictionaryEntry "name" (mkVariant "Default rounded"))
          (mkDictionaryEntry "effects" (mkVariant [
            (mkVariant [
              (mkDictionaryEntry "type" (mkVariant "native_static_gaussian_blur"))
              (mkDictionaryEntry "id" (mkVariant "effect_000000000001"))
              (mkDictionaryEntry "params" (mkVariant [
                (mkDictionaryEntry "radius" (mkVariant 30.0))
                (mkDictionaryEntry "brightness" (mkVariant 0.6))
              ]))
            ])
            (mkVariant [
              (mkDictionaryEntry "type" (mkVariant "corner"))
              (mkDictionaryEntry "id" (mkVariant "effect_000000000002"))
              (mkDictionaryEntry "params" (mkVariant [
                (mkDictionaryEntry "radius" (mkVariant 24.0))
              ]))
            ])
          ]))
        ]))
      ];
      
      settings-version = 2;
    };

    "org/gnome/shell/extensions/openbar" = {
        bartype = "Mainland";
        bwidth = 0.0;
        font = config.stylix.fonts.sansSerif.name + " Bold " + toString config.stylix.fonts.sizes.applications;
        neon = false;
        menu-radius = 15;
        hpad = 1.0;
        vpad = 4.0;
        height = 32;
        fgcolor = [ "${base05-dec-r}" "${base05-dec-g}" "${base05-dec-b}" ];
        hcolor = [ "${base0D-dec-r}" "${base0D-dec-g}" "${base0D-dec-b}" ];
        dark-fgcolor = [ "${base05-dec-r}" "${base05-dec-g}" "${base05-dec-b}" ];
        mfgcolor = [ "${base05-dec-r}" "${base05-dec-g}" "${base05-dec-b}" ];
        dark-mfgcolor = [ "${base05-dec-r}" "${base05-dec-g}" "${base05-dec-b}" ];
        mbgcolor = [ "${base00-dec-r}" "${base00-dec-g}" "${base00-dec-b}" ];
        dark-mbgcolor = [ "${base00-dec-r}" "${base00-dec-g}" "${base00-dec-b}" ];
        mbcolor = [ "${base05-dec-r}" "${base05-dec-g}" "${base05-dec-b}" ];
        dark-mbcolor = [ "${base05-dec-r}" "${base05-dec-g}" "${base05-dec-b}" ];
        smbgcolor = [ "${base02-dec-r}" "${base02-dec-g}" "${base02-dec-b}" ];
        dark-smbgcolor = [ "${base02-dec-r}" "${base02-dec-g}" "${base02-dec-b}" ];
        mscolor = [ "${base0D-dec-r}" "${base0D-dec-g}" "${base0D-dec-b}" ];
        dark-mscolor = [ "${base0D-dec-r}" "${base0D-dec-g}" "${base0D-dec-b}" ];
        mhcolor = [ "${base05-dec-r}" "${base05-dec-g}" "${base05-dec-b}" ];
        dark-mhcolor = [ "${base05-dec-r}" "${base05-dec-g}" "${base05-dec-b}" ];
        bgalpha = 0.0;
        mfgalpha = 1.0;
        mbgalpha = 1.0;
        mbalpha = 0.15;
        mhalpha = 0.15;
        mshalpha = 0.0;
        menustyle = true;
        autohg-bar = false;
        autohg-menu = false;
        autotheme-refresh = false;
        auto-bgalpha = false;
        autofg-bar = false;
        reloadstyle = true;
        autofg-menu = false;
        trigger-reload = true;
        smbgoverride = true;
        accent-override = false;
    };

    "org/gnome/shell/extensions/paperwm" = {
      selection-border-size = 0;
      show-focus-mode-icon = false;
      show-open-position-icon = false;
      show-workspace-indicator = false;
    };

    "org/gnome/shell/weather" = {
      automatic-location = true;
    };

    "org/gnome/system/location" = {
      enabled = true;
    };

    # Custom keybinding: Super+T opens Ghostty
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ghostty/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ghostty" = {
      binding = "<Super>t";
      command = "ghostty";
      name = "Open terminal";
    };
  };

  ########################################
  # Firefox (profile-level config)
  ########################################

  programs.firefox = {
    enable = true;

    profiles.user = {
      id = 0;
      isDefault = true;

      settings = {
        "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
        # "browser.startup.homepage" = "https://nixos.org";
      };

      search = {
        engines = {
          "Nix Packages" = {
            definedAliases = [ "@np" ];
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [{ name = "query"; value = "{searchTerms}"; }];
            }];
          };

          "Nix Options" = {
            definedAliases = [ "@no" ];
            urls = [{
              template = "https://search.nixos.org/options";
              params = [{ name = "query"; value = "{searchTerms}"; }];
            }];
          };
        };

        force = true;
      };
    };
  };

  ########################################
  # XDG defaults (terminal + MIME)
  ########################################

  xdg.terminal-exec = {
    enable = true;
    settings.default = [ "ghostty.desktop" ];
  };

  xdg.mimeApps = {
    associations.added = {
      "text/html" = "firefox.desktop";
      "text/xml"  = "firefox.desktop";
    };
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "text/xml"  = "firefox.desktop";
    };
  };

  ########################################
  # Profile image: ~/.face from Stylix-colored avatar
  ########################################

  home.file.".face".source = stylixFace;

  ########################################
  # Stylix targets for user-scoped apps
  ########################################

  stylix.targets = {
    firefox = {
      enable = true;
      profileNames = [ "user" ];
      firefoxGnomeTheme.enable = true;
    };  
    ghostty.enable = true;
    nixcord.enable = true;
  };

  home.stateVersion = "24.05";
}
