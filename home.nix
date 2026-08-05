{ config, pkgs, pkgs-stable, lib, dotfiles, ... }:
let
  seclists = pkgs.callPackage ./pkgs/seclists.nix { };
  msf-database = pkgs.callPackage ./config/metasploit/database.nix { };
  gitdumper = pkgs.python3Packages.callPackage ./pkgs/gitdumper.nix { };
  dirsearch = pkgs.python3Packages.callPackage ./pkgs/dirsearch.nix { };

  python-packages = ps: with ps; [
    impacket
    pwntools
    pyftpdlib
    dirsearch
  ];

  metasploit-stable = pkgs-stable.metasploit;
in
{
  home.username = "vncsb";
  home.homeDirectory = "/home/vncsb";
  home.stateVersion = "26.05";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
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
    terminus-nerdfont
    gobuster
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
    raccoon
    metasploit-stable
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
    bloodhound
    bloodhound-py
    sslscan
    wpscan
    gitdumper
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
    crackmapexec
    openssl
    dnsrecon
    amass
    ansifilter
    inetutils
    rdesktop
    nasm
    proxychains-ng
    chisel
  ];

  xsession.windowManager.awesome = {
    enable = true;
  };

  programs.home-manager.enable = true;

  home.file = {
    ".zshrc".source = "${dotfiles}/.zshrc";
    ".p10k.zsh".source = "${dotfiles}/.p10k.zsh";
    ".tmux.conf".source = "${dotfiles}/.tmux.conf";
    ".ensure-tmux-logging.sh".source = "${dotfiles}/.ensure-tmux-logging.sh";
    "wordlists/seclists".source = seclists;
    ".msf4/database.yml".text = msf-database;
  };
}
