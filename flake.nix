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
    systems = {
      kde = "x86_64-linux";
      hyprland = "x86_64-linux";
      work-mac = "x86_64-darwin";
    };

  in {
    nixosConfigurations = {

      kde = nixpkgs.lib.nixosSystem {
        system = systems.kde;
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/kde/configuration.nix ];
      };

      hyprland = nixpkgs.lib.nixosSystem {
        system = systems.hyprland;
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/hyprland/configuration.nix ];
      };
      
    };

    darwinConfigurations = {

      work-mac = nix-darwin.lib.darwinSystem {
        system = systems.work-mac;
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
  };
}
