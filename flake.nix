{
  description = "Deploy Linglong anywhere";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ]
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          
          linyaps-box = pkgs.callPackage (self.outPath + "/linglong/linyaps-box.nix") { };
          
          linyaps = pkgs.callPackage (self.outPath + "/linglong") {
            inherit linyaps-box;
            bash = pkgs.bash;
            binutils = pkgs.binutils;
            coreutils = pkgs.coreutils;
            desktop-file-utils = pkgs.desktop-file-utils;
            erofs-utils = pkgs.erofs-utils;
            fuse3 = pkgs.fuse3;
            fuse-overlayfs = pkgs.fuse-overlayfs;
            gnutar = pkgs.gnutar;
            glib = pkgs.glib;
            shared-mime-info = pkgs.shared-mime-info;
          };
        in
        {
          packages = {
            inherit linyaps-box linyaps;
          };

          nixosModules = { config, lib, ... }:
            with lib;
            let cfg = config.services.linyaps; in
            {
              options = {
                services.linyaps = {
                  enable = mkEnableOption "linyaps" // {
                    default = true;
                  };
                };
              };

              config = mkIf cfg.enable {
                environment = {
                  profiles = [ "${linyaps}/etc/profile.d" ];
                  sessionVariables.LINGLONG_ROOT = "/var/lib/linglong";
                  systemPackages = [ linyaps ];
                };

                services.dbus.packages = [ linyaps ];

                systemd = {
                  packages = [ linyaps ];
                  tmpfiles.rules = [
                    "C /var/lib/linglong 0775 deepin-linglong deepin-linglong - ${linyaps}"
                    "Z /var/lib/linglong 0775 deepin-linglong deepin-linglong - -"
                    "d /var/log/linglong 0757 root root - -"
                  ];
                };

                users = {
                  groups.deepin-linglong = { };
                  users.deepin-linglong = {
                    group = "deepin-linglong";
                    isSystemUser = true;
                  };
                };
              };
            };
        });
}
