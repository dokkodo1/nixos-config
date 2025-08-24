{
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
    disko,
    impermanence,
    nixos-anywhere,
    nix-gaming,
    nix-citizen,
    neovim-nightly-overlay,
    ...
  }@inputs:
  let

    systems = {
      desktop = "x86_64-linux";
      work-mac = "x86_64-darwin";
      nixtop = "x86_64-linux";
      #hpls1 = "x86_64-linux";
#      rpi4 = "aarch64-linux";
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
      desktop = mkNixOSSystem {
        system = systems.desktop;
        hostPath = ./hosts/desktop/configuration.nix;
      };

      nixtop = mkNixOSSystem {
        system = systems.nixtop;
        hostPath = ./hosts/nixtop/configuration.nix;
      };

#      hpls1 = mkNixOSSystem {
#        system = systems.hpls1;
#        hostPath = ./hosts/hpls1/configuration.nix;
#      };

#      rpi4 = mkNixOSSystem {
#        system = systems.rpi4;
#        hostPath = ./hosts/rpi4/configuration.nix;
#        extraModules = [
#          inputs.disko.nixosModules.disko
#          inputs.impermanence.nixosModules.impermanence
#        ];
#      };
    };

    homeConfigurations = {
      "dokkodo@desktop" = mkHomeConfig {
        system = systems.desktop;
        user = "dokkodo";
        hostPath = ./hosts/desktop/home.nix;
      };

      "dokkodo@nixtop" = mkHomeConfig {
        system = systems.nixtop;
        user = "dokkodo";
        hostPath = ./hosts/nixtop/home.nix;
      };

#      "dokkodo@hpls1" = mkHomeConfig {
#        system = systems.hpls1;
#        user = "dokkodo";
#        hostPath = ./hosts/hpls1/home.nix;
#      };

#      "dokkodo@rpi4" = mkHomeConfig {
#        system = systems.rpi4;
#        user = "dokkodo";
#        hostPath = ./hosts/rpi4/home.nix;
#      };
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

    devShells = nixpkgs.lib.genAttrs 
      (nixpkgs.lib.attrValues systems)
      (system: 
        let pkgs = mkPkgs system;
        in pkgs.mkShell {
          buildInputs = with pkgs; [
            nixos-rebuild
            home-manager
            git
          ];
          shellHook = ''
            echo "Nix development environment loaded"
            echo "Available commands: nixos-rebuild, home-manager"
          '';
        });

    formatter = nixpkgs.lib.genAttrs 
      (nixpkgs.lib.attrValues systems)
      (system: (mkPkgs system).nixpkgs-fmt);
  };
}
