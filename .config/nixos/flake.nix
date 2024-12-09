{
  description = "system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, spicetify-nix, ... }@inputs: 
  { 
    nixosConfigurations.JJ-Desktop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";


      modules = [
        (import ./configuration.nix inputs)
	(import ./desktop.nix inputs)
      ];
    };
    nixosConfigurations.fbi-van-laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        (import ./configuration.nix inputs)
	(import ./fbi-van.nix inputs)
      ];
    };
 };
}
