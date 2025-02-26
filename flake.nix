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

  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let

    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  
  in 
  {

    nixosConfigurations = {

      default = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/default/configuration.nix
        ];
      };

      gamestation = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/gamestation/configuration.nix
        ];
      };
    };

#    homeConfigurations = {
#      "dokkodo" = home-manager.lib.homeManagerConfiguration {
#        inherit pkgs;
#        extraSpecialArgs = { inherit inputs; };
#        modules = [
#          ./hosts/gamestation/home.nix
#        ];
#      };
#
#    };
  };
}
