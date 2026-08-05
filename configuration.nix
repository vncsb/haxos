{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
let
  lain = pkgs.callPackage ./pkgs/lain.nix { lua = pkgs.lua5_3; };
  dirsearch = pkgs.callPackage ./pkgs/dirsearch.nix { };

  python-packages =
    ps: with ps; [
      impacket
      pwntools
      pyftpdlib
      dirsearch
    ];
in
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    gcc
    git
    tmux
    zsh
    alacritty
    neovim
    chromium
    firefox
    eza
    meslo-lgs-nf
    nerd-fonts.terminess-ttf
    gobuster
    feroxbuster
    dirsearch
    seclists
    nodejs
    xsel
    ripgrep
    fd
    wget
    rustc
    cargo
    go
    openvpn
    unzip
    metasploit
    nmap
    nssTools
    zap
    burpsuite
    (python3.withPackages python-packages)
    bruno
    cadaver
    thc-hydra
    openldap
    enum4linux
    netexec
    samba
    kerbrute
    updog
    rclone
    exploitdb
    john
    evil-winrm
    bloodhound-ce
    bloodhound-py
    sslscan
    wpscan
    git-dumper
    sqlmap
    wireshark
    exiftool
    whatweb
    wafw00f
    onesixtyone
    snmpcheck
    nfs-utils
    jq
    dig
    responder
    openssl
    dnsrecon
    amass
    ansifilter
    inetutils
    rdesktop
    nasm
    proxychains-ng
    chisel
    ligolo-ng
    zoxide
    direnv
    uv
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.availableKernelModules = [
      "virtio_net"
      "virtio_blk"
      "virtio_pci"
      "virtio_scsi"
      "virtio_balloon"
    ];
    initrd.kernelModules = [
      "virtio_blk"
      "virtio_scsi"
    ];
  };

  networking = {
    hostName = "haxos";
    firewall.trustedInterfaces = [
      "tun0"
    ];
  };

  programs.zsh.enable = true;
  virtualisation.docker.enable = true;

  services = {
    xserver = {
      enable = true;
      windowManager.awesome = {
        enable = true;
        luaModules = with pkgs.luaPackages; [
          luarocks
          lain
        ];
      };
    };
    displayManager = {
      autoLogin.enable = true;
      autoLogin.user = "vncsb";
    };
  };

  services = {
    rpcbind.enable = true;
    nfs.server.enable = true;
    spice-vdagentd.enable = true;
    qemuGuest.enable = true;
  };

  users.users.vncsb = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    initialPassword = "vncsb";
    shell = pkgs.zsh;
  };

  environment.shells = with pkgs; [ zsh ];

  environment.sessionVariables = {
    WINIT_X11_SCALE_FACTOR = "1.44";
  };

  environment.etc.hosts.mode = "0644";

  system.stateVersion = "26.05";
}
