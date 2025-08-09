{
  inputs.linglong-flake.url = "..";

  outputs = inputs@{ self, linglong-flake }: let 
    nixpkgs = linglong-flake.inputs.nixpkgs;
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        linglong-flake.nixosModules.linyaps

        {
        imports = [ "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix" ];
        environment.systemPackages = with pkgs; [
          gdb
          binutils
        ];

        services.linyaps.enable = true;
        
        # 启用SSH服务
        services.openssh = {
          enable = true;
          settings = {
            PermitRootLogin = "yes";
            PasswordAuthentication = true;
            X11Forwarding = true;
          };
        };
        
        services.xserver = {
          enable = true;
          displayManager = {
            lightdm.enable = true;
          };
          desktopManager.lxqt.enable = true;
        };

        services.displayManager.autoLogin = {
          enable = true;
          user = "test";
        };

        time.timeZone = "Asia/Shanghai";
        i18n = {
          defaultLocale = "en_US.UTF-8";
          supportedLocales = [ "zh_CN.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
        };
        users.users.test = {
          isNormalUser = true;
          uid = 1000;
          extraGroups = [ "wheel" "networkmanager" ];
          password = "test";
        };
        virtualisation = {
          qemu.options = [ "-device intel-hda -device hda-duplex" ];
          cores = 8;
          memorySize = 8192;
          diskSize = 16384;
          resolution = { x = 1024; y = 768; };
        };
        system.stateVersion = "23.11";
      }];
    };
    packages.${system}.default = self.nixosConfigurations.vm.config.system.build.vm;
    apps.${system}.default = {
      type = "app";
      program = "${self.packages.${system}.default}/bin/run-nixos-vm";
    };
  };
}
