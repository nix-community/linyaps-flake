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
          
          # 添加 debug 配置选项
          debug = false;
          
          linyaps-box = pkgs.callPackage (self.outPath + "/pkgs/linyaps-box.nix") { 
            inherit debug;
          };
          
          linyaps = pkgs.callPackage (self.outPath + "/pkgs") {
            inherit debug;
          };
        in
        {
          packages = {
            inherit linyaps-box linyaps;
            
            # 添加 debug 版本的包
            linyaps-box-debug = pkgs.callPackage (self.outPath + "/pkgs/linyaps-box.nix") { 
              debug = true;
            };
            linyaps-debug = pkgs.callPackage (self.outPath + "/pkgs") {
              debug = true;
            };
          };
        }) // {
          nixosModules = {
            linyaps = { config, lib, pkgs, ... }:
              with lib;
              let 
                cfg = config.services.linyaps;
                # 支持 debug 配置选项
                debug = cfg.debug or true; # 默认开启 debug
                linyaps-box = if debug then 
                  self.packages.${pkgs.system}.linyaps-box 
                else 
                  pkgs.callPackage (self.outPath + "/pkgs/linyaps-box.nix") { debug = false; };
                linyaps = if debug then 
                  self.packages.${pkgs.system}.linyaps 
                else 
                  pkgs.callPackage (self.outPath + "/pkgs") { 
                    debug = false; 
                  };
              in
              {
                options = {
                  services.linyaps = {
                    enable = mkEnableOption "linyaps" // {
                      default = true;
                    };
                    debug = mkOption {
                      type = types.bool;
                      default = true;
                      description = "是否启用 debug 版本（包含调试信息和符号表）";
                    };
                  };
                };

                config = mkIf cfg.enable {
                  environment = {
                    profiles = [ "${linyaps}/etc/profile.d" ];
                    sessionVariables.LINGLONG_ROOT = "/var/lib/linglong";
                    systemPackages = [ linyaps linyaps-box ];
                    
                    # 添加/etc配置文件
                    etc = {
                      "profile.d/linglong.sh" = {
                        source = "${linyaps}/etc/profile.d/linglong.sh";
                        mode = "0644";
                      };
                      "X11/Xsession.d/21linglong" = {
                        source = "${linyaps}/etc/X11/Xsession.d/21linglong";
                        mode = "0644";
                      };
                      "tmpfiles.d/linglong.conf" = {
                        source = "${linyaps}/lib/tmpfiles.d/linglong.conf";
                        mode = "0644";
                      };
                    };
                  };

                  services.dbus.packages = [ linyaps ];

                  systemd = {
                    packages = [ linyaps ];
                    tmpfiles.rules = [
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
        };
}
