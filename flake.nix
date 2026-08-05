{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      disko
    }@inputs:
    {
      nixosConfigurations = {
        haxos = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            disko.nixosModules.disko
            ./configuration.nix
            ./disko-config.nix
          ];
        };
      };
    };
}
