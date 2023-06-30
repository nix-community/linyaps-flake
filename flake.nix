{
  description = "Deploy Linglong anywhere";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ]
      (system:
        {
          packages = flake-utils.lib.flattenTree (
            import ./. { pkgs = nixpkgs.legacyPackages.${system}; }
          );

          nixosModules = { config, lib, ... }:
            with lib;
            with self.packages.${system};
            let cfg = config.services.linglong; in
            {
              options = {
                services.linglong = {
                  enable = mkEnableOption "linglong" // {
                    default = true;
                  };
                };
              };

              config = mkIf cfg.enable {
                environment = {
                  profiles = [ "${linglong}/etc/profile.d" ];
                  sessionVariables.LINGLONG_ROOT = "/var/lib/linglong";
                  systemPackages = [ linglong ];
                };

                services.dbus.packages = [ linglong ];

                systemd = {
                  packages = [ linglong ];
                  tmpfiles.rules = [
                    "C /var/lib/linglong 0775 deepin-linglong deepin-linglong - ${linglong-root}"
                    "Z /var/lib/linglong 0775 deepin-linglong deepin-linglong - -"
                    "d /var/log/linglong 0757 root root - -"
                  ];
                };

                users = {
                  groups.deepin-linglong = { };
                  users.deepin-linglong = {
                    description = "Linglong daemon user";
                    home = "/var/lib/linglong";
                    createHome = false;
                    group = "deepin-linglong";
                    isSystemUser = true;
                  };
                };
              };
            };
        });
}
