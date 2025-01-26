{
  description = "dokkodo's desktop flake";

  inputs = {

    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ### STAR CITIZEN STUFF 
    nix-citizen.url = "github:LovingMelody/nix-citizen";

    # Optional - updates underlying without waiting for nix-citizen to update
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-citizen.inputs.nix-gaming.follows = "nix-gaming";
    ### ^^^^
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:

  let

    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };

  in {

    # NixOS Setup
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.dokkodo = import ./home.nix;
          }
        ];
      };
    };
  };
}
