{
  # disko config for Framework 13 (12th-gen Intel) on /dev/nvme0n1
  #
  # Save as: disko-framework13-impermanence.nix
  #
  # From the installer:
  #   nix run github:nix-community/disko -- --mode disko ./disko-framework13-impermanence.nix

  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";

        # For long-term reliability, you probably want /dev/disk/by-id/...
        device = "/dev/nvme0n1";

        content = {
          type = "gpt";
          partitions = {
            ESP = {
              name = "ESP";
              type = "EF00";
              size  = "1G";  # 1 GiB EFI system partition
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            swap = {
              name = "swap";
              type = "8200";
              size = "32G"; # adjust if you want bigger/smaller or hibernate-friendly
              content = {
                type = "swap";
                # randomEncryption = true; # optional
              };
            };

            root = {
              name = "root";
              size  = "100%";  # use the rest of the disk
              content = {
                type = "btrfs";

                # base mount options for all btrfs subvolumes
                mountOptions = [
                  "compress=zstd"
                  "ssd"
                  "noatime"
                ];

                subvolumes = {
                  "@root" = {
                    mountpoint = "/";
                    # Root will be "ephemeral" via impermanence (tmpfiles + bind mounts),
                    # not via snapshot tricks.
                  };

                  "@nix" = {
                    mountpoint = "/nix";
                    # keeping /nix persistent dramatically speeds up rebuilds
                  };

                  "@persist" = {
                    mountpoint = "/persist";
                    # This is the backing store for impermanence.
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
