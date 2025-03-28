{
  description = "evan main flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";

    nix-gaming.url = "github:fufexan/nix-gaming";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-gaming, ... }@inputs:
  let
    systems = {
      kde = "x86_64-linux";
    };

  in {
    nixosConfigurations = {

      kde = nixpkgs.lib.nixosSystem {
        system = systems.kde;
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/kde/configuration.nix ];
      };
      
    };
  };
}
