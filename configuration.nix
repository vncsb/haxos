{ config, pkgs, lib, modulesPath, ... }:
let
  lain = pkgs.callPackage ./pkgs/lain.nix { lua = pkgs.lua5_3; };
in
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPatches = lib.singleton {
    name = "enable-nfs-v2";
    patch = null;
    extraStructuredConfig = with lib.kernel; {
        NFS_V2 = module;
      };
    };

  networking.firewall.trustedInterfaces = [
    "tun0"
  ];

  programs.zsh.enable = true;
  virtualisation.docker.enable = true;

  services.xserver = {
    enable = true;
    windowManager.awesome = {
      enable = true;
      luaModules = [ lain ];
    };
    displayManager = {
      autoLogin.enable = true;
      autoLogin.user = "haxos";

      sessionCommands = ''
        ${pkgs.xorg.xrandr}/bin/xrandr --newmode "3440x1440_60.00" 419.11 3440 3688 4064 4688 1440 1441 1444 1490 -HSync +VSync &&
        ${pkgs.xorg.xrandr}/bin/xrandr --addmode Virtual-1 3440x1440_60.00 &&
        ${pkgs.xorg.xrandr}/bin/xrandr --output Virtual-1 --mode 3440x1440_60.00 
      '';
    };
  };

  services.postgresql = {
    enable = true;
    initialScript = pkgs.writeText "init-msf-database" ''
      CREATE ROLE msf_user WITH LOGIN;
      CREATE DATABASE msf_database OWNER msf_user;
      GRANT ALL PRIVILEGES ON DATABASE msf_database TO msf_user;
    '';
    authentication = pkgs.lib.mkForce ''
      # TYPE  DATABASE USER ADDRESS        METHOD
        local all      all                 trust
        host  all      all  127.0.0.1/32   trust
        host  all      all  ::1/128        trust
    '';
  };

  services = {
    rpcbind.enable = true;
    nfs.server.enable = true;
    spice-vdagentd.enable = true;
  };

  users.users.haxos = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    initialPassword = "nix";
    shell = pkgs.zsh;
  };

  environment.shells = with pkgs; [ zsh ];

  environment.sessionVariables = {
    WINIT_X11_SCALE_FACTOR = "1.44";
  };

  environment.etc.hosts.mode = "0644";

  system.build.qcow = lib.mkForce (import "${toString modulesPath}/../lib/make-disk-image.nix" {
    inherit lib config pkgs;
    diskSize = "auto";
    additionalSpace = "5G";
    format = "qcow2";
    partitionTableType = "hybrid";
  });

  system.stateVersion = "23.11";
}
