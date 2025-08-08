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
          
          linyaps-box = pkgs.callPackage (self.outPath + "/pkgs/linyaps-box.nix") { };
          
          linyaps = pkgs.callPackage (self.outPath + "/pkgs") {
            inherit linyaps-box;
          };
        in
        {
          packages = {
            inherit linyaps-box linyaps;
          };
        }) // {
          nixosModules.linyaps = { config, lib, pkgs, ... }:
            with lib;
            let 
              cfg = config.services.linyaps;
              linyaps-box = self.packages.${pkgs.system}.linyaps-box;
              linyaps = self.packages.${pkgs.system}.linyaps;
            in
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
                    "C /var/lib/linglong 0775 deepin-linglong deepin-linglong - -"
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

                # 添加systemd服务配置
                systemd.services = {
                  "org.deepin.linglong.PackageManager1" = {
                    description = "Linyaps Package Manager Service";
                    wantedBy = [ "multi-user.target" ];
                    serviceConfig = {
                      Type = "dbus";
                      BusName = "org.deepin.linglong.PackageManager1";
                      ExecStart = "${linyaps}/libexec/linglong/ll-package-manager";
                      Restart = "on-failure";
                    };
                  };
                };

                # 添加systemd用户服务
                systemd.user.services = {
                  "linglong-session-helper" = {
                    description = "Linyaps Session Helper";
                    wantedBy = [ "default.target" ];
                    serviceConfig = {
                      ExecStart = "${linyaps}/libexec/linglong/ll-session-helper";
                      Restart = "on-failure";
                    };
                  };
                };

                # 添加polkit规则
                security.polkit.extraConfig = ''
                  polkit.addRule(function(action, subject) {
                    if (action.id == "org.deepin.linglong.PackageManager1.install" &&
                        subject.local && subject.active && subject.isInGroup("deepin-linglong")) {
                      return polkit.Result.YES;
                    }
                  });
                '';
              };
            };
        };
}
