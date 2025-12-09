{
  description = "dokkodo main flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    impermanence.url = "github:nix-community/impermanence";
    
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.disko.follows = "disko";
    };

    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-citizen = {
      url = "github:LovingMelody/nix-citizen";
      inputs.nix-gaming.follows = "nix-gaming";
    };

		musnix.url = "github:musnix/musnix";
		native-access-nix = {
			url = "github:yusefnapora/native-access-nix";
			inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    hostname = "nixtop";
    username = "dokkodo"; 
    darwinHostname = "work-mac";
    darwinUsername = "callummcdonald";
    locale = "en_ZA.UTF-8";
    systems = {
      desktop = "x86_64-linux";
      work-mac = "x86_64-darwin";
      nixtop = "x86_64-linux";
    };

    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
      (final: prev: {
        doxpkgs = prev.callPackage ./pkgs { };
      })
    ];

    mkNixOSSystem = { system, hostPath, extraModules ? [] }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs username hostname locale; modPath = ./modules; };
        modules = [
          inputs.musnix.nixosModules.musnix
          inputs.home-manager.nixosModules.home-manager
          inputs.sops-nix.nixosModules.sops
          inputs.nur.modules.nixos.default
          ({ pkgs, ... }: {
            nixpkgs.overlays = overlays;
            nixpkgs.config.allowUnfree = true;
            nixpkgs.config.packageOverrides = pkgs: {
              stable = import inputs.nixpkgs-stable {
                system = pkgs.system;
                config.allowUnfree = true;
              };
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            documentation.man.enable = true;
            documentation.nixos.enable = true;
          })
          hostPath
        ] ++ extraModules;
      };

  in {
    nixosConfigurations.${hostname} = mkNixOSSystem {
      system = systems.${hostname};
      hostPath = ./hosts/${hostname}/configuration.nix;
    };

    darwinConfigurations.${darwinHostname} = inputs.nix-darwin.lib.darwinSystem {
      system = systems.${darwinHostname};
      specialArgs = { inherit inputs darwinUsername darwinHostname locale; modPath = ./modules; };
      modules = [
        ./hosts/${darwinHostname}/configuration.nix
        inputs.home-manager.darwinModules.home-manager
        inputs.sops-nix.darwinModules.sops
        {
          nixpkgs.overlays = overlays;
          nixpkgs.config.allowUnfree = true;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; modPath = ./modules; };
            #home-manager.users.${darwinUsername} = import ./hosts/${darwinHostname}/home.nix;
        }
      ];
    };

    formatter = nixpkgs.lib.genAttrs 
      (nixpkgs.lib.attrValues systems)
      (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
  };
}
