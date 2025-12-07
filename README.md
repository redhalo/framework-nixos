# Framework 13 (12th-gen) NixOS Config

Ephemeral, themed, gaming-ready NixOS config for a **Framework 13 (12th-gen Intel)** laptop.

Highlights:

- 🧱 **NixOS with flakes** on **`nixos-unstable`** (with a `nixos-24.05` stable pocket as `pkgs.stable`)
- 🧊 **Btrfs + tmpfs root + impermanence**
  - `/` on **tmpfs** (ephemeral)
  - `/nix` + `/persist` on **btrfs subvolumes**
- 🖥️ **GNOME** on **Wayland** with GDM themed to match your session
- 🎨 **Stylix** for full theming
  - Custom Base16 scheme in `themes/robert-base16.nix`
  - `lutgen`-recolored wallpaper
  - Recolored avatar piped to `~/.face`
  - Firefox themed and GNOME-integrated
- 🧵 **Ghostty** terminal + **zsh + oh-my-zsh**
- 🔐 **1Password** (GUI + CLI + shell plugins) + Firefox integration
- 🎮 **Gaming stack**
  - Steam (+ gamescope session, extest)
  - Gamescope, Gamemode
  - MangoHud overlay
- 🛠️ **Dev tooling**
  - Python 3.12 toolchain (poetry, black, ruff, mypy, ipython)
  - `direnv` + `nix-direnv` for flake dev shells
  - VS Code (official Microsoft build)
- 🧹 **Nix & system hygiene**
  - Automatic Nix GC + optimise
  - `nix-index` + `nix-index-database-comma`
  - Firewall, fwupd, btrfs autoscrub
  - `systemd.user.startServices = "sd-switch"`

---

## Repository layout

```text
framework-nixos/
├── README.md
├── flake.nix
├── configuration.nix
├── hardware-configuration.nix
├── home.nix
├── disko-framework13-impermanence.nix
├── themes
│   └── robert-base16.nix
├── wallpapers
│   └── wallpaper.jpg
└── avatars
    └── profile.png
```

Most files are wired together via `flake.nix` and `configuration.nix`. `hardware-configuration.nix` has placeholder UUIDs you should update with your actual disk IDs.

---

## Nixpkgs: unstable by default + stable pocket

The flake uses:

- **`nixpkgs`** → `nixos-unstable` (default for system and user packages)
- **`nixpkgs-stable`** → `nixos-24.05`, imported via an overlay as `pkgs.stable`

Unfree is enabled globally in `configuration.nix`:

```nix
nixpkgs.config = {
  allowUnfree = true;
};
```

The overlay exposes `pkgs.stable`:

```nix
{
  nixpkgs.overlays = [
    (final: prev: {
      stable = import nixpkgs-stable {
        inherit system;
        config = { allowUnfree = true; };
      };
    })
  ];
}
```

Usage examples:

```nix
# system (configuration.nix)
environment.systemPackages = with pkgs; [
  vim
  git
  # unstable by default

  stable.libreoffice  # explicitly from stable
];

# home (home.nix)
home.packages =
  (with pkgs; [
    neovim
    # ...
    stable.spotify
  ])
  ++ (with pkgs.gnomeExtensions; [ ... ]);
```

---

## Disk layout & impermanence

See `disko-framework13-impermanence.nix` for the desired partitioning on `/dev/nvme0n1`:

- EFI (`/boot`)
- swap
- btrfs root with subvolumes: `@root`, `@nix`, `@persist`

`hardware-configuration.nix` then mounts:

- `/` as tmpfs (ephemeral)
- `/nix` as btrfs subvolume `@nix`
- `/persist` as btrfs subvolume `@persist` (with `neededForBoot = true;`)

Impermanence is configured in `configuration.nix` via:

```nix
environment.persistence."/persist" = {
  enable = true;
  hideMounts = true;

  directories = [ ... ];
  files = [ ... ];

  users.robert = {
    directories = [
      "Documents" "Downloads" "Music" "Pictures" "Videos"
      ".config" ".local/share" ".local/state" ".ssh" ".gnupg"
      ".local/share/Steam" ".steam"
    ];
  };
};
```

Everything outside `/nix` and those persisted paths resets on reboot.

---

## Theming (Stylix, wallpaper, avatar)

Stylix is enabled in `configuration.nix` with:

- `base16Scheme = import ./themes/robert-base16.nix;`
- `image = wallpaper;` where `wallpaper` is a `lutgen`-recolored version of `./wallpapers/wallpaper.jpg`
- Fonts (`FiraCode Nerd Font`, `Noto Sans/Serif`, `Noto Color Emoji`)
- Cursor theme (`phinger-cursors`)
- Targets:
  - Firefox (with GNOME Firefox theme)
  - Console and Plymouth explicitly **disabled** for Stylix theming

In `home.nix`, an avatar at `./avatars/profile.png` is recolored with `lutgen` using the same Base16 palette, and installed as `~/.face` via Home Manager. GDM picks this up as the user icon.

---

## GNOME & GDM

`configuration.nix` enables:

- GNOME (Wayland) via `services.xserver.desktopManager.gnome.enable = true;`
- GDM via `services.xserver.displayManager.gdm.enable = true;` with Wayland

System-wide GNOME gsettings are set to:

- Use the Stylix-colored wallpaper for:
  - Desktop background
  - Screensaver
  - GDM background
- Prefer dark color scheme
- Use 12-hour clock without date in the top bar

User-specific GNOME settings (extensions, keybindings, favorites, etc.) are handled in `home.nix` via `dconf.settings`.

---

## Shell, terminal & dev

- Default shell: `zsh` (with oh-my-zsh) for user `robert`
- Terminal: `ghostty`, themed by Stylix in `home.nix`, bound to **Super+T**, and set as the XDG default terminal.
- Dev tooling:
  - Python 3.12 (`python312Full`)
  - `pipx`, `virtualenv`, `poetry`
  - `ipython`, `black`, `ruff`, `mypy`
- `direnv` + `nix-direnv` for flake-based dev shells

VS Code (official Microsoft build) is enabled via `programs.vscode` in `configuration.nix`.

---

## Browser & 1Password

Firefox is:

- Installed and configured at the system level (`programs.firefox` policies)
- Themed via Stylix’ Firefox target and the GNOME Firefox theme
- Configured with a `user` profile via Home Manager:
  - Custom search engines (`Nix Packages`, `Nix Options`)
  - UI tweaks (tab bar hidden via `userChrome`)

1Password:

- Desktop app is enabled (`programs._1password-gui`)
- CLI + shell plugins for tools like `gh`
- Firefox integration is allowed via `/etc/1password/custom_allowed_browsers` containing `firefox`

---

## Gaming

Steam is enabled with:

- Remote Play and dedicated server firewall rules
- Gamescope session integration
- `extest` for better controller support

Also enabled:

- `programs.gamescope`
- `programs.gamemode`
- `programs.mangohud` (with a useful HUD configuration)

---

## Nix housekeeping & safety

- Automatic Nix GC weekly (`--delete-older-than 7d`)
- Automatic Nix store optimisation
- `nix-index` + `nix-index-database.comma`
- Firewall enabled
- Firmware updates via `fwupd`
- Monthly btrfs `autoScrub` on `/nix` and `/persist`
- `systemd.user.startServices = "sd-switch"` for smoother Home Manager/systemd user service reloads

---

## Timezone & location

- Static fallback timezone: `America/New_York`
- Dynamic timezone: `services.automatic-timezoned.enable = true;`
- Geolocation via `geoclue2` pointing at `https://beacondb.net/v1/geolocate`

GNOME’s weather and location settings in `home.nix` are configured to automatically use this data.

---

## Install / reinstall

From a NixOS installer:

1. Connect to Wi-Fi (e.g. via NetworkManager).
2. Clone this repo.
3. Run `disko` with `disko-framework13-impermanence.nix` to partition `/dev/nvme0n1`.
4. Mount the resulting filesystems to `/mnt` according to `hardware-configuration.nix`.
5. Run `nixos-generate-config --root /mnt` if needed and adjust `hardware-configuration.nix` UUIDs.
6. Install:

   ```bash
   nixos-install --root /mnt --flake .#framework-13
   ```

7. Reboot and log in as `robert`.

Apply changes with:

```bash
sudo nixos-rebuild switch --flake .#framework-13
```

Because Home Manager is integrated as a NixOS module, this single command updates both system and user config.
