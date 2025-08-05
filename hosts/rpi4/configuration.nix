{ config, pkgs, lib, inputs, modPath, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ./disk-config.nix
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
  ] ++ map (file: modPath + "/system/" + file) [
    "programs/systemPackages.nix"
    "services/networking.nix"
    "services/ssh.nix"
    "settings/nixSettings.nix"
    "settings/users.nix"
  ];

  networking.hostName = "rpi4";
  system.stateVersion = "24.11";

  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;
    
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    
    kernelParams = [
      "8250.nr_uarts=1"
      "console=ttyAMA0,115200"
      "console=tty1"
      "cma=64M"
    ];
    
    # Use tmpfs for tmp to reduce SD writes
    tmp.useTmpfs = true;
  };

  # Disable X11 for headless setup (conflicts with your minimalX.nix)
  services.xserver.enable = lib.mkForce false;
  
  # Override sound config for headless (conflicts with your sound.nix)
  hardware.pulseaudio.enable = lib.mkForce false;
  services.pipewire.enable = lib.mkForce false;
  
  # Disable bluetooth for headless (conflicts with your bluetooth.nix)  
  hardware.bluetooth.enable = lib.mkForce false;

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      "/etc/ssh"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
    users.dokkodo = {
      directories = [
        "configurations"
        "Documents"
        "Downloads"
        ".local/share"
        ".config"
        ".cache"
        ".ssh"
      ];
      files = [
        ".zsh_history"
      ];
    };
  };

  # Create persist directory on first boot
  system.activationScripts.createPersistDir = ''
    mkdir -p /persist
  '';

  hardware = {
    raspberry-pi."4" = {
      apply-overlays-dtmerge.enable = true;
      dt-overlays = {
        disable-wifi = {
          enable = false;
          params = {};
        };
      };
    };
    i2c.enable = true;
  };
  
  services = {
    timesyncd.enable = true;
    openssh.settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    
    # Reduce journal writes to SD card
    journald.extraConfig = ''
      Storage=volatile
      RuntimeMaxUse=64M
    '';
  };

  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L"
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };
}