{ config, lib, pkgs, ... }:

{
  imports = [
    (import ./flake.nix).nixosModules.x86_64-linux
  ];

  services.linyaps.enable = true;

  # 测试配置
  system.stateVersion = "23.11";
} 