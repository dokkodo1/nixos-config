{
  description = "dokkodo main flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    #nixpkgs-local.url = "github:dokkodo1/nixpkgs/tmux-plugin-powerkit";
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

    tmux-powerkit.url = "github:dokkodo1/tmux-powerkit/add-nix-packaging";
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    lib = nixpkgs.lib;
    hostDirs = lib.filterAttrs (n: v: v == "directory" && !lib.hasPrefix "default" n) (builtins.readDir ./hosts);
    mkHostVars = hostname: (import ./hosts/${hostname}/meta.nix) // { inherit hostname; };
    isLinuxHost = hostname: let meta = import ./hosts/${hostname}/meta.nix; in lib.hasSuffix "-linux" meta.system;
    isDarwinHost = hostname: let meta = import ./hosts/${hostname}/meta.nix; in lib.hasSuffix "-darwin" meta.system;
    linuxHosts = lib.filterAttrs (n: _: isLinuxHost n) hostDirs;
    darwinHosts = lib.filterAttrs (n: _: isDarwinHost n) hostDirs;

    # Collect all host SSH public keys for cross-host authorization
    allHostKeys = lib.pipe (builtins.attrNames hostDirs) [
      (map (name: (import ./hosts/${name}/meta.nix).hostSshKey or null))
      (lib.filter (k: k != null))
    ];

    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
      (final: prev: {
        doxpkgs = prev.callPackage ./pkgs { };
      })
    ];

    mkNixOSSystem = { hostname, extraModules ? [] }:
      let
        hostVars = mkHostVars hostname;
      in nixpkgs.lib.nixosSystem {
        system = hostVars.system;
        specialArgs = { inherit inputs hostVars allHostKeys; modPath = ./modules; };
        modules = [
          inputs.musnix.nixosModules.musnix
          inputs.home-manager.nixosModules.home-manager
          inputs.sops-nix.nixosModules.sops
          inputs.nur.modules.nixos.default
          inputs.disko.nixosModules.disko
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
          ./hosts/${hostname}/configuration.nix
          ./modules/nixos
        ] ++ extraModules;
      };

    mkDarwinSystem = { hostname, extraModules ? [] }:
      let
        hostVars = mkHostVars hostname;
      in inputs.nix-darwin.lib.darwinSystem {
        system = hostVars.system;
        specialArgs = { inherit inputs hostVars allHostKeys; modPath = ./modules; };
        modules = [
          ./modules/darwin
          ./hosts/${hostname}/configuration.nix
          inputs.home-manager.darwinModules.home-manager
          inputs.sops-nix.darwinModules.sops
          {
            nixpkgs.overlays = overlays ++ [
              (final: prev: {
                basedpyright = (import inputs.nixpkgs-stable {
                  system = prev.stdenv.hostPlatform.system;
                }).basedpyright;
              })
            ];
            nixpkgs.config.allowUnfree = true;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs hostVars allHostKeys; modPath = ./modules; };
          }
        ] ++ extraModules;
      };

  in {
    nixosConfigurations = lib.mapAttrs (hostname: _: mkNixOSSystem { inherit hostname; }) linuxHosts;
    darwinConfigurations = lib.mapAttrs (hostname: _: mkDarwinSystem { inherit hostname; }) darwinHosts;

    formatter = let allSystems = lib.unique (lib.mapAttrsToList (n: _: (import ./hosts/${n}/meta.nix).system) hostDirs);
    in lib.genAttrs allSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
  };
}
