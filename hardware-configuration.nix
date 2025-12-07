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
    device = "/dev/disk/by-uuid/CHANGE-ME-BTRFS-UUID";
    fsType = "btrfs";
    options = [ "subvol=@nix" "compress=zstd" "ssd" "noatime" ];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/CHANGE-ME-BTRFS-UUID";
    fsType = "btrfs";
    options = [ "subvol=@persist" "compress=zstd" "ssd" "noatime" ];
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/CHANGE-ME-ESP-UUID";
    fsType = "vfat";
  };

  swapDevices = [
    { device = "/dev/disk/by-partuuid/CHANGE-ME-SWAP-PARTUUID"; }
  ];

  # Basic hardware toggles
  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable = true;

  # This file is a template; adjust UUIDs and options to match your system.
}
