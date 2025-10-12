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

    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
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

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    nixos-hardware,
    nur,
    home-manager,
    nix-darwin,
    sops-nix,
    disko,
    impermanence,
    nixos-anywhere,
		chaotic,
    nix-gaming,
    nix-citizen,
		musnix,
		native-access-nix,
    neovim-nightly-overlay,
    ...
  }@inputs:
  let

    username = "dokkodo";

    systems = {
      desktop = "x86_64-linux";
      work-mac = "x86_64-darwin";
      nixtop = "x86_64-linux";
			audionix = "x86_64-linux";
      gaming = "x86_64-linux";
    };

    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
      # Custom packages overlay
      (final: prev: {
        doxpkgs = prev.callPackage ./pkgs { }; # can be called through pkgs.dokpkgs.testScript
        
        # Example custom package - add your own derivations here
        # my-custom-tool = final.callPackage ./pkgs/my-custom-tool { };
        
        # Example: override existing package
        # vim = prev.vim.override { ... };
      })
    ];

    sharedNixOSModules = [
      sops-nix.nixosModules.sops
      nur.modules.nixos.default
      ({ config, pkgs, ... }: {
        nixpkgs.overlays = overlays;
        nixpkgs.config.allowUnfree = true;
        # Make stable packages available as pkgs.stable
        nixpkgs.config.packageOverrides = pkgs: {
          stable = import nixpkgs-stable {
            system = pkgs.system;
            config.allowUnfree = true;
          };
        };
				documentation.man.enable = true;
				documentation.nixos.enable = true;
      })
    ];

    mkNixOSSystem = { system, hostPath, extraModules ? [] }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs username;
          modPath = ./modules;
        };
        modules = sharedNixOSModules ++ [ hostPath ] ++ extraModules;
      };

    mkPkgs = system: import nixpkgs {
      inherit system overlays;
      config = {
        allowUnfree = true;
        # Make stable packages available in Home Manager too
        packageOverrides = pkgs: {
          stable = import nixpkgs-stable {
            system = pkgs.system;
            config.allowUnfree = true;
          };
        };
      };
    };

    mkHomeConfig = { system, user, hostPath }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs system;
        extraSpecialArgs = {
          inherit inputs;
          modPath = ./modules;
        };
        modules = [ hostPath ];
      };

  in {
    nixosConfigurations = {
      desktop = mkNixOSSystem {
        system = systems.desktop;
        hostPath = ./hosts/desktop/configuration.nix;
				extraModules = [
				  inputs.chaotic.nixosModules.default
				];
      };

      nixtop = mkNixOSSystem {
        system = systems.nixtop;
        hostPath = ./hosts/nixtop/configuration.nix;
      };

       audionix = mkNixOSSystem {
        system = systems.audionix;
        hostPath = ./hosts/audionix/configuration.nix;
				extraModules = [
				  inputs.musnix.nixosModules.musnix
				];
      };

      gaming = mkNixOSSystem {
        system = systems.gaming;
        hostPath = ./hosts/gaming/configuration.nix;
				extraModules = [
				  inputs.chaotic.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.users.${username} = import ./hosts/gaming/home.nix;
          }
				];
      };

    };

    homeConfigurations = {
      "${username}@desktop" = mkHomeConfig {
        system = systems.desktop;
        user = username;
        hostPath = ./hosts/desktop/home.nix;
      };

      "${username}@nixtop" = mkHomeConfig {
        system = systems.nixtop;
        user = "dokkodo";
        hostPath = ./hosts/nixtop/home.nix;
      };

      "${username}@audionix" = mkHomeConfig {
        system = systems.audionix;
        user = "dokkodo";
        hostPath = ./hosts/audionix/home.nix;
      };
    };

    darwinConfigurations = {
      work-mac = nix-darwin.lib.darwinSystem {
        system = systems.work-mac;
        specialArgs = {
          inherit inputs;
          modPath = ./modules;
        };
        modules = [
          ./hosts/work-mac/configuration.nix
          home-manager.darwinModules.home-manager
          # When using nix-darwin save the age key to $HOME/Library/Application Support/sops/age/keys.txt
          # or set a custom configuration directory (https://github.com/getsops/sops#23encrypting-using-age)
          sops-nix.darwinModules.sops
          {
            nixpkgs.overlays = overlays;
            nixpkgs.config.allowUnfree = true;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              modPath = ./modules;
            };
            home-manager.users.callummcdonald = import ./hosts/work-mac/home.nix;
          }
        ];
      };
    };

    formatter = nixpkgs.lib.genAttrs 
      (nixpkgs.lib.attrValues systems)
      (system: (mkPkgs system).nixpkgs-fmt);
  };
}
