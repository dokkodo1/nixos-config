{
  # refactor
  description = "dokkodo main flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

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
    home-manager,
    nix-darwin,
    sops-nix,
		chaotic,
    nix-gaming,
    nix-citizen,
		musnix,
		native-access-nix,
    neovim-nightly-overlay,
    ...
  }@inputs:
  let

    systems = {
      default = "x86_64-linux";
      work-mac = "x86_64-darwin";
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
			inputs.chaotic.nixosModules.default
			inputs.native-access-nix.nixosModules.default
      sops-nix.nixosModules.sops
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
          inherit inputs;
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
      default = mkNixOSSystem {
        system = systems.default;
        hostPath = ./hosts/default/configuration.nix;
				extraModules = [
				];
      };

    homeConfigurations = {
      "dokkodo@default" = mkHomeConfig {
        system = systems.default;
        user = "dokkodo";
        hostPath = ./hosts/default/home.nix;
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
  };
}
