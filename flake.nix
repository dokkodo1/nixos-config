{
  description = "dokkodo main flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";

    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-citizen = {
      url = "github:LovingMelody/nix-citizen";
      inputs.nix-gaming.follows = "nix-gaming";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, home-manager, nix-gaming, nix-citizen, nix-darwin, ... }@inputs:
  let

    systemsMap = {
      kde = "x86_64-linux";
      desktop = "x86_64-linux";
      work-mac = "x86_64-darwin";
    };

    pkgsFor = system: import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      # Add overlays if needed for HM pkgs, e.g.:
      # overlays = [ inputs.some-overlay.overlays.default ];
    };


  in {
    nixosConfigurations = {

      kde = nixpkgs.lib.nixosSystem {
        system = systemsMap.kde;
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/kde/configuration.nix ];
      };

      desktop = nixpkgs.lib.nixosSystem {
        system = systemsMap.desktop;
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/desktop/configuration.nix ];
      };      
      
    };

# <<< Home-manager as standalone >>>
    homeConfigurations = {

      "dokkodo@kde" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor systemsMap.kde;
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./hosts/kde/home.nix ];
      };

      "dokkodo@desktop" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor systemsMap.desktop;
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./hosts/desktop/home.nix ];
      };

      # Example for potential future work-mac standalone HM config
      # "callummcdonald@work-mac" = home-manager.lib.homeManagerConfiguration {
      #   pkgs = pkgsFor systemsMap.work-mac; # Using the same pkgs function
      #   extraSpecialArgs = { inherit inputs; };
      #   modules = [ ./hosts/work-mac/home.nix ];
      # };

    }; 
# ^^^ Comment out if using hm as module ^^^

# <<< nix darwin >>>
    darwinConfigurations = {

      work-mac = nix-darwin.lib.darwinSystem {
        system = systemsMap.work-mac;
        specialArgs = { inherit inputs; };
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
