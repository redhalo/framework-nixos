{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Root on tmpfs (ephemeral)
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "mode=755" "size=12G" ];
  };

  # Btrfs subvolumes (update UUID to your disk's UUID)
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/09559925-2eb5-4ef3-a721-f0cefd7dc0b9";
    fsType = "btrfs";
    options = [ "subvol=@nix" "compress=zstd" "ssd" "noatime" ];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/09559925-2eb5-4ef3-a721-f0cefd7dc0b9";
    fsType = "btrfs";
    options = [ "subvol=@persist" "compress=zstd" "ssd" "noatime" ];
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/E2A2-965F";
    fsType = "vfat";
  };

  swapDevices = [
    { device = "/dev/disk/by-partuuid/fef1e0d6-f8b3-4e6e-ba0d-0cfbf80b5cd4"; }
  ];

  # Basic hardware toggles
  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable = true;

  # This file is a template; adjust UUIDs and options to match your system.
}
