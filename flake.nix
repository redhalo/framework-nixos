{
  description = "Framework 13 (12th-gen Intel) NixOS configuration for robert";

  inputs = {
    # Main nixpkgs – everything defaults to unstable
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Secondary stable channel
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    _1password-shell-plugins.url = "github:1Password/shell-plugins";

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-stable
    , home-manager
    , nixos-hardware
    , stylix
    , _1password-shell-plugins
    , impermanence
    , ...
    }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations."framework-13" = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./configuration.nix

          # Hardware
          nixos-hardware.nixosModules.framework-12th-gen-intel

          # Theming & impermanence
          stylix.nixosModules.stylix
          impermanence.nixosModules.impermanence

          # 1Password shell plugins
          _1password-shell-plugins.nixosModules.default

          # Overlay: expose stable as pkgs.stable
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

          # Home Manager as a NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users."robert" = import ./home.nix;
          }
        ];
      };
    };
}
