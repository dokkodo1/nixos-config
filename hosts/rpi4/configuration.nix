{ config, pkgs, lib, inputs, modPath, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ./disk-config.nix
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
    (modPath + "/system")
  ];

  networking.hostName = "rpi4";
  system.stateVersion = "24.11";

  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;
    
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    
    # Enable GPU acceleration
    kernelParams = [
      "8250.nr_uarts=1"
      "console=ttyAMA0,115200"
      "console=tty1"
      # Reduce GPU memory for headless setup
      "cma=64M"
    ];
  };

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

  # ===== Hardware Configuration =====
  hardware = {
    # Enable GPU
    raspberry-pi."4" = {
      apply-overlays-dtmerge.enable = true;
      dt-overlays = {
        disable-wifi = {
          enable = false;
          params = {};
        };
      };
    };
    #pulseaudio.enable = lib.mkForce false;
    i2c.enable = true;
  };
  
  #services = {
  #  xserver.enable = lib.mkForce false;
  #  timesyncd.enable = true;
  #};

  services.openssh.settings = {
    PermitRootLogin = "no";
    PasswordAuthentication = false;
  };

  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L" # print build logs
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };
  
  # Reduce writes to SD card
  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=64M
  '';

  # Mount tmpfs for tmp
  boot.tmp.useTmpfs = true;
}  
