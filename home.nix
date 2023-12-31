{ config, pkgs, lib, ... }:
let
  dotfiles = pkgs.fetchgit {
    url = "https://github.com/vncsb/dotfiles.git";
    rev = "3dceee1a966523270e99fab689f5f9cd99ecb09d";
    hash = "sha256-qsNeaL9b2taENlWHHvwrJjqn5+9gHZqA7W3O0hKsXOM=";
    fetchSubmodules = true;
  };
  gobuster = pkgs.callPackage ./pkgs/gobuster.nix { };
  seclists = pkgs.callPackage ./pkgs/seclists.nix { };
  raccoon = pkgs.callPackage ./pkgs/raccoon.nix { };
  gitdumper = pkgs.python3Packages.callPackage ./pkgs/gitdumper.nix { };

  python-packages = ps: with ps; [
    impacket
    pwntools
  ];
in
{
  home.username = "haxos";
  home.homeDirectory = "/home/haxos";
  home.stateVersion = "23.05";

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
    rustup
    go
    openvpn
    unzip
    raccoon
    metasploit
    nmap
    nssTools
    zap
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
  ];

  xsession.windowManager.awesome = {
    enable = true;
  };

  programs.home-manager.enable = true;

  xdg.configFile = {
    "awesome" = {
      source = "${dotfiles}/.config/awesome";
      recursive = true;
    };
    "nvim" = {
      source = "${dotfiles}/.config/nvim";
      recursive = true;
    };
    "alacritty" = {
      source = "${dotfiles}/.config/alacritty";
      recursive = true;
    };
  };

  home.file = {
    ".zshrc".source = "${dotfiles}/.zshrc";
    ".p10k.zsh".source = "${dotfiles}/.p10k.zsh";
    ".tmux.conf".source = "${dotfiles}/.tmux.conf";
    "wordlists/seclists".source = seclists;
  };

  home.activation.install-root-certificate =
    let
      zap = "${pkgs.zap}/bin/zap";
      certutil = "${pkgs.nssTools}/bin/certutil";
      awkPath = "${pkgs.gawk}/bin";
    in
      lib.hm.dag.entryAfter [ "installPackages" ] ''
        export PATH="$PATH:${awkPath}"
        $DRY_RUN_CMD ${zap} -addoninstall network -cmd $VERBOSE_ARG
        $DRY_RUN_CMD ${zap} -certpubdump $HOME/zap-certificate.cer -cmd $VERBOSE_ARG
        $DRY_RUN_CMD mkdir -p $HOME/.pki/nssdb
        $DRY_RUN_CMD ${certutil} -d $HOME/.pki/nssdb -N --empty-password
        $DRY_RUN_CMD ${certutil} -d sql:$HOME/.pki/nssdb/ -A -t "CP,CP," -n zap-certificate -i $HOME/zap-certificate.cer $VERBOSE_ARG
      '';
}
