{ pkgs, inputs, ... }:
{
  programs = {
    vim.enable = true;
  };

  environment.systemPackages = with pkgs; [

    # archiving
    gnutar
    gzip
    xz
    bzip2
    unzip
    rar
    zstd
    p7zip

    # utils
    coreutils
    gnugrep
    ripgrep
    gnused
    gawk
    findutils
    diffutils
    file
    less
    man-db
    tree
    bat

    # networking/web
    curl
    wget
    dnsutils
    inetutils
    iproute2
    w3m-nox

    # processes
    btop
    lsof
    strace
    pciutils
    usbutils
    dmidecode
    ncdu

    # mounting/storage
    parted
    dosfstools
    ntfs3g
    exfatprogs

    # misc
    git
    bitwarden-cli
    tmux

    # nix
    nh
    home-manager # <<< remove if using home-manager as module
  ];
}
