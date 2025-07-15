{
  description = "dokkodo main flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-gaming.url = "github:fufexan/nix-gaming";

    nix-citizen.url = "github:LovingMelody/nix-citizen";
    nix-citizen.inputs.nix-gaming.follows = "nix-gaming";
  };

  outputs = inputs@{
    self,
    nixpkgs,
    nixpkgs-stable,
    nixos-hardware,
    home-manager,
    nix-darwin,
    nix-gaming,
    nix-citizen,
    ...
  }:
  let

    # ----- HELPERS ----- #
    systemsMap = {
      desktop = "x86_64-linux";
      work-mac = "x86_64-darwin";
      nixtop = "x86_64-linux";
      rpi4 = "aarch_64-linux";
      defaultHost = "aarch_64-linux";
    };

    pkgsFor = system: import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      # Add overlays if needed for HM pkgs, e.g.:
      # overlays = [ inputs.some-overlay.overlays.default ];
    };


  in {
    nixosConfigurations = {

      desktop = nixpkgs.lib.nixosSystem {
        system = systemsMap.desktop;
        specialArgs = {
          inherit userSettings;
          inherit inputs;
        };
        modules = [
          ./hosts/desktop/configuration.nix
        ];
      };

      nixtop = nixpkgs.lib.nixosSystem {
        system = systemsMap.nixtop;
        specialArgs = {
          inherit userSettings;
          inherit inputs;
        };
        modules = [
          ./hosts/nixtop/configuration.nix
        ];
      };       
      
      rpi4 = nixpkgs.lib.nixosSystem {
        system = systemsMap.rpi4;
        specialArgs = {
          inherit userSettings;
          inherit inputs;
        };
        modules = [
          ./hosts/rpi4/configuration.nix
        ];
      };       

      defaultHost = nixpkgs.lib.nixosSystem {
        system = systemsMap.defaultHost;
        specialArgs = {
          inherit userSettings;
          inherit inputs;
        };
        modules = [
          ./hosts/defaultHost/configuration.nix
        ];
      };       
    };
# <<< Home-manager as standalone >>>
    homeConfigurations = {

      "dokkodo@desktop" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor systemsMap.desktop;
        extraSpecialArgs = {
          inherit userSettings;
          inherit inputs;
        };
        modules = [
          ./hosts/desktop/home.nix
        ];
      };
      
      "dokkodo@nixtop" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor systemsMap.nixtop;
        extraSpecialArgs = {
          inherit userSettings;
          inherit inputs;
        };
        modules = [
          ./hosts/nixtop/home.nix
        ];
      };
      
      "dokkodo@rpi4" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor systemsMap.rpi4;
        extraSpecialArgs = {
          inherit userSettings;
          inherit inputs;
        };
        modules = [
          ./hosts/rpi4/home.nix
        ];
      };

      "dokkodo@defaultHost" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor systemsMap.defaultHost;
        extraSpecialArgs = {
          inherit userSettings;
          inherit inputs;
        };
        modules = [
          ./hosts/defaultHost/home.nix
        ];
      };
      # Example for potential future work-mac standalone HM config
      # "callummcdonald@work-mac" = home-manager.lib.homeManagerConfiguration {
      #   pkgs = pkgsFor systemsMap.work-mac;
      #   extraSpecialArgs = { inherit inputs; };
      #   modules = [ ./hosts/work-mac/home.nix ];
      # };

    }; 
# ^^^ Comment out if using hm as module ^^^

# <<< nix darwin >>>
    darwinConfigurations = {

      work-mac = nix-darwin.lib.darwinSystem {
        system = systemsMap.work-mac;
        specialArgs = {
          inherit userSettings;
          inherit inputs;
        };
        modules = [
          ./hosts/work-mac/configuration.nix
          home-manager.darwinModules.home-manager
          {
            #home-manager.useGlobalPkgs = false;
            #home-manager.useUserPkgs = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users."callummcdonald" = import ./hosts/work-mac/home.nix;
          }
        ];
      };
    };
#         ^^^   WIP   ^^^

  };
}
