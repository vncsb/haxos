{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
let
  lain = pkgs.callPackage ./pkgs/lain.nix { lua = pkgs.lua5_3; };
in
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPatches = lib.singleton {
    name = "enable-nfs-v2";
    patch = null;
    structuredExtraConfig = with lib.kernel; {
      NFS_V2 = module;
    };
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
        luaModules = [ lain ];
      };
      displayManager = {
        sessionCommands = ''
          ${pkgs.xrandr}/bin/xrandr --newmode "3440x1440_60.00" 419.11 3440 3688 4064 4688 1440 1441 1444 1490 -HSync +VSync &&
          ${pkgs.xrandr}/bin/xrandr --addmode Virtual-1 3440x1440_60.00 &&
          ${pkgs.xrandr}/bin/xrandr --output Virtual-1 --mode 3440x1440_60.00 
        '';

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
