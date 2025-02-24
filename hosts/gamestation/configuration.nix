# NOT EDITED AT ALL
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
	./hardware-configuration.nix
	inputs.home-manager.nixosModules.default
    #Overlay
	./../../modules/nixos/sddm.nix
	./../../modules/nixos/WindowManager.nix
	./../../modules/nixos/FileManager/thunar.nix
    #System	
	./../../modules/nixos/fonts.nix
	./../../modules/nixos/homeoffice.nix
	./../../modules/nixos/Shell/htp.nix
	./../../modules/nixos/Shell/system-tools.nix
    #Settings
	./../../modules/nixos/Settings/hardware.nix
	./../../modules/nixos/Settings/keyboard-layout.nix
	./../../modules/nixos/Settings/time.nix
	./../../modules/nixos/Settings/users.nix
    #Services
	./../../modules/nixos/Services/firewall.nix
	./../../modules/nixos/Services/networking.nix
	./../../modules/nixos/Services/ssh.nix
	./../../modules/nixos/Services/bluetooth.nix
	./../../modules/nixos/Services/sound.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "Nix-Tower";

  #Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes"];
  
  home-manager = {
	#also pass inputs to home-manager modules
	extraSpecialArgs = {inherit inputs; };
	users = {
	"tjey" = import ./home.nix;
	};
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  services.xserver.enable = true;

  security.pam.services.hyprlock = {};
  security.pam.services.swaylock = {};

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  system.stateVersion = "24.11";
}
