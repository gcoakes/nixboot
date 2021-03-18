{
  description = "PXE boot a NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (
        system: let
          pkgs = nixpkgs.legacyPackages.${system};
        in
          rec {
            nixosConfigurations.netboot = nixpkgs.lib.nixosSystem {
              inherit system;
              modules = [ nixosModule ];
            };
            nixosModule = { modulesPath, lib, ... }: with lib; {
              imports = [ "${modulesPath}/installer/netboot/netboot-minimal.nix" ];
              services.getty.autologinUser = mkForce "root";
              systemd.services.sshd.wantedBy = mkOverride 0 [ "multi-user.target" ];
            };
            packages = let
              build = nixosConfigurations.netboot.config.system.build;
            in
              {
                inherit (build) kernel;
                initrd = build.netbootRamdisk;
              };
          }
      );
}
