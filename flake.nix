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
    repoName = "configurations"; # name of this folder
    hostname = "nixtop";
    username = "dokkodo"; 
    darwinHostname = "work-mac"; # these two only apply if building nix darwin. can leave null
    darwinUsername = "callummcdonald"; # don't @ me
    locale = "en_ZA.UTF-8";
      # copy and rename the folder ./hosts/default and add that name and system to this list
      # if not me, delete these 3 entries and add your own. 
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
        specialArgs = { inherit inputs username hostname locale repoName; modPath = ./modules; };
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
      # will build the current host, for personal use. nixosConfigurations attrs grows quickly when you got nix everywhere
    nixosConfigurations.${hostname} = mkNixOSSystem {
      system = systems.${hostname};
      hostPath = ./hosts/${hostname}/configuration.nix;
      # you can pass in `extraModules = [ ];` here, or if you make individual hosts, not this over-generalized mess (:
    };

    darwinConfigurations.${darwinHostname} = inputs.nix-darwin.lib.darwinSystem {
      system = systems.${darwinHostname};
      specialArgs = { inherit inputs darwinUsername darwinHostname locale repoName; modPath = ./modules; };
      modules = [
        ./hosts/${darwinHostname}/configuration.nix
        inputs.home-manager.darwinModules.home-manager
        inputs.sops-nix.darwinModules.sops
        {
          nixpkgs.overlays = overlays;
          nixpkgs.config.allowUnfree = true;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs darwinUsername darwinHostname locale repoName; modPath = ./modules; };
        }
      ];
    };

    formatter = nixpkgs.lib.genAttrs 
      (nixpkgs.lib.attrValues systems)
      (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
  };
}
